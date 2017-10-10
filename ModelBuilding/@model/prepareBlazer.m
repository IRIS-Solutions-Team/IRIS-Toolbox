function blz = prepareBlazer(this, kind, opt)
% prepareBlazer  Create Blazer object from dynamic or steady equations.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

try, isBlocks = opt.blocks; catch, isBlocks = true; end %#ok<NOCOM>
try, lsEndg = opt.endogenize; catch, lsEndg = [ ]; end; %#ok<NOCOM>
try, lsExg = opt.exogenize; catch, lsExg = [ ]; end; %#ok<NOCOM>

%--------------------------------------------------------------------------

ixy = this.Quantity.Type==TYPE(1);
ixx = this.Quantity.Type==TYPE(2);
ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
ixp = this.Quantity.Type==TYPE(4);
ixm = this.Equation.Type==TYPE(1);
ixt = this.Equation.Type==TYPE(2);
ixmt = ixm | ixt;
numOfEquations = length(this.Equation);

blz.Quantity = this.Quantity;
switch lower(kind)
    case 'steady'
        blz = solver.blazer.Steady(numOfEquations);
        blz.Equation(ixmt) = this.Equation.Steady(ixmt);
        ixCopy = ixmt & cellfun(@isempty, this.Equation.Steady(1, :));        
        blz.Equation(ixCopy) = this.Equation.Dynamic(ixCopy);
        blz.Gradient(:, ixmt) = this.Gradient.Steady(:, ixmt);
        blz.Gradient(:, ixCopy) = this.Gradient.Dynamic(:, ixCopy);
        blz.Incidence = this.Incidence.Steady;
        incid = across(blz.Incidence, 'Shift');
        blz.IxCanBeEndg = (ixy | ixx | ixp) & full(any(incid, 1));
        blz.Assignment = this.Pairing.Assignment.Steady;

    case 'dynamic'
        blz = solver.blazer.Dynamic(numOfEquations);
        blz.Equation(ixmt) = this.Equation.Dynamic(ixmt);
        blz.Gradient(:, ixmt) = this.Gradient.Dynamic(:, ixmt);
        blz.Incidence = selectShift(this.Incidence.Dynamic, 0);
        incid = across(blz.Incidence, 'Shift');
        blz.IxCanBeEndg = (ixy | ixx | ixe) & full(any(incid, 1));
        blz.Assignment = this.Pairing.Assignment.Dynamic;

    case 'stacked'
        numOfStackedTimes = opt.Stacked;
        blz = solver.blazer.Stacked(numOfStackedTimes, numOfEquations);
        blz.Equation(ixmt) = this.Equation.Dynamic(ixmt);
        blz.Gradient(:, :) = [ ];
        blz.Incidence = this.Incidence.Dynamic;
        blz.IxCanBeEndg = ixy | ixx;
        blz.Assignment = this.Pairing.Assignment.Dynamic;

    otherwise
        throw( ...
            exception.Base('General:Internal', 'error') ...
        );
end

% Change log status of variables.
if isfield(opt, 'Unlog') && ~isempty(opt.Unlog)
    this.Quantity = chgLogStatus(this.Quantity, opt.Unlog, false);
end
blz.IxLog = this.Quantity.IxLog;

blz.IxEndg = ixy | ixx;
blz.IxEqn = ixm | ixt;
blz.IsBlocks = isBlocks;

if isequal(lsExg, @auto) || isequal(lsEndg, @auto)
    [lsExg, lsEndg] = resolveAutoexog(this, kind, lsExg, lsEndg);
end

if ischar(lsEndg)
    lsEndg = regexp(lsEndg, '\w+', 'match');
end
lsEndg = unique(lsEndg);
if ~isempty(lsEndg)
    outp = lookup(this.Quantity, lsEndg);
    vecEndg = outp.PosName;
    error = endogenize(blz, vecEndg);
    if any(error.IxCannotSwap)
        throw( ...
            exception.Base('Blazer:CannotEndogenize', 'error'), ...
            lsEndg{error.IxCannotSwap} ...
            );
    end
end

if ischar(lsExg)
    lsExg = regexp(lsExg, '\w+', 'match');
end
lsExg = unique(lsExg);
if ~isempty(lsExg)
    outp = lookup(this.Quantity, lsExg);
    vecExg = outp.PosName;
    error = exogenize(blz, vecExg);
    if any(error.IxCannotSwap)
        throw( ...
            exception.Base('Blazer:CannotExogenize', 'error'), ...
            lsExg{error.IxCannotSwap} ...
            );
    end
end

end
