function blz = prepareBlazer(this, kind, varargin)
% prepareBlazer  Create Blazer object from dynamic or steady equations
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

TYPE = @int8;

persistent parser
if isempty(parser)
    parser = extend.InputParser('model.prepareBlazer');
    parser.KeepUnmatched = true;
    parser.addRequired('Model', @(x) isa(x, 'model'));
    parser.addRequired('Kind', @(x) ischar(x) && any(strcmpi(x, {'Steady', 'Current', 'Stacked'})));
    parser.addParameter('Blocks', true, @(x) isequal(x, true) || isequal(x, false));
    parser.addSwapOptions( );
end
parser.parse(this, kind, varargin{:});
opt = parser.Options;

%--------------------------------------------------------------------------

ixy = this.Quantity.Type==TYPE(1);
ixx = this.Quantity.Type==TYPE(2);
ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
ixp = this.Quantity.Type==TYPE(4);
ixm = this.Equation.Type==TYPE(1);
ixt = this.Equation.Type==TYPE(2);
ixmt = ixm | ixt;
numOfEquations = length(this.Equation);

if strcmpi(kind, 'Steady')
    blz = solver.blazer.Steady(numOfEquations);
    blz.Equation(ixmt) = this.Equation.Steady(ixmt);
    inxCopy = ixmt & cellfun(@isempty, this.Equation.Steady(1, :));        
    blz.Equation(inxCopy) = this.Equation.Dynamic(inxCopy);
    blz.Gradient(:, ixmt) = this.Gradient.Steady(:, ixmt);
    blz.Gradient(:, inxCopy) = this.Gradient.Dynamic(:, inxCopy);
    blz.Incidence = this.Incidence.Steady;
    incid = across(blz.Incidence, 'Shift');
    blz.InxCanBeEndogenous = ixy | ixx | ixp;
    blz.Assignment = this.Pairing.Assignment.Steady;

elseif strcmpi(kind, 'Period')
    blz = solver.blazer.Dynamic(numOfEquations);
    blz.Equation(ixmt) = this.Equation.Dynamic(ixmt);
    blz.Gradient(:, ixmt) = this.Gradient.Dynamic(:, ixmt);
    blz.Incidence = selectShift(this.Incidence.Dynamic, 0);
    incid = across(blz.Incidence, 'Shift');
    blz.InxCanBeEndogenous = ixy | ixx | ixe;
    blz.Assignment = this.Pairing.Assignment.Dynamic;

elseif strcmpi(kind, 'Stacked')
    blz = solver.blazer.Stacked(numOfEquations);
    blz.Equation(ixmt) = this.Equation.Dynamic(ixmt);
    blz.Gradient(:, :) = [ ];
    blz.Incidence = this.Incidence.Dynamic;
    blz.InxCanBeEndogenous = ixy | ixx | ixe;
    blz.Assignment = this.Pairing.Assignment.Dynamic;

else
    throw( exception.Base('General:Internal', 'error') );
end
blz.Quantity = this.Quantity;

% Change log status of variables
if isfield(opt, 'Unlog') && ~isempty(opt.Unlog)
    blz.Quantity = changeLogStatus(blz.Quantity, opt.Unlog, false);
end

blz.InxEndogenous = ixy | ixx;
blz.InxEquations = ixm | ixt;
blz.IsBlocks = opt.Blocks;

if isequal(opt.Exogenize, @auto) || isequal(opt.Endogenize, @auto)
    [listExogenize, listEndogenize] = resolveAutoexog(this, kind, opt.Exogenize, opt.Endogenize);
else
    listExogenize = opt.Exogenize;
    listEndogenize = opt.Endogenize;
end

if ischar(listEndogenize)
    listEndogenize = regexp(listEndogenize, '\w+', 'match');
elseif ~iscellstr(listEndogenize)
    listEndogenize = cellstr(listEndogenize);
end
listEndogenize = unique(listEndogenize);
if ~isempty(listEndogenize)
    outp = lookup(blz.Quantity, listEndogenize);
    vecEndg = outp.PosName;
    error = endogenize(blz, vecEndg);
    if any(error.IxCannotSwap)
        throw( exception.Base('Blazer:CannotEndogenize', 'error'), ...
               listEndogenize{error.IxCannotSwap} );
    end
end

if ischar(listExogenize)
    listExogenize = regexp(listExogenize, '\w+', 'match');
elseif ~iscellstr(listExogenize)
    listExogenize = cellstr(listExogenize);
end
listExogenize = unique(listExogenize);
if ~isempty(listExogenize)
    outp = lookup(blz.Quantity, listExogenize);
    vecExg = outp.PosName;
    error = exogenize(blz, vecExg);
    if any(error.IxCannotSwap)
        throw( exception.Base('Blazer:CannotExogenize', 'error'), ...
               listExogenize{error.IxCannotSwap} );
    end
end

end%

