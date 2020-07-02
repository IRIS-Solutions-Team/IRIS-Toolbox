function [blz, opt] = prepareBlazer(this, kind, varargin)
% prepareBlazer  Create Blazer object from dynamic or steady equations
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

TYPE = @int8;

% Parse input arguments
%(
persistent pp
if isempty(pp)
    pp = extend.InputParser('Model.prepareBlazer');
    pp.KeepUnmatched = true;

    addRequired(pp, 'Model', @(x) isa(x, 'model'));
    addRequired(pp, 'Kind', @locallyValidateKind);

    addParameter(pp, 'Blocks', true, @(x) isequal(x, true) || isequal(x, false));
    addParameter(pp, 'Log', { }, @locallyValidateLogList);
    addParameter(pp, 'Unlog', { }, @locallyValidateLogList);
    addParameter(pp, 'Growth', @auto, @(x) isequal(x, @auto) || isequal(x, true) || isequal(x, false));
    addParameter(pp, 'SaveAs', '', @(x) isempty(x) || ischar(x));
    addSwapFixOptions(pp);
end
parse(pp, this, kind, varargin{:});
opt = pp.Options;
%)

if isequal(opt.Growth, @auto)
    opt.Growth = this.IsGrowth;
end

%--------------------------------------------------------------------------

inxY = this.Quantity.Type==TYPE(1);
inxX = this.Quantity.Type==TYPE(2);
inxE = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
inxP = this.Quantity.Type==TYPE(4);
inxM = this.Equation.Type==TYPE(1);
inxT = this.Equation.Type==TYPE(2);
inxYX = inxY | inxX;
inxMT = inxM | inxT;
numEquations = numel(this.Equation);
numQuantities = numel(this.Quantity);

if strcmpi(kind, 'Steady')
    %
    % Steady state solution
    %
    blz = solver.blazer.Steady(numEquations);

    [inxPwL, inxLwP] = hereGetParameterLinks( ); % [^1]
    % [^1]: inxPwL is the index of parameters that are LHS names in links;
    % inxLwP is the index of equations that are links with parameters on
    % the LHS

    blz.InxEndogenous = inxYX | inxPwL;
    blz.InxEquations = inxMT | inxLwP ;
    blz.InxCanBeEndogenized = inxP & ~inxPwL;
    blz.InxCanBeExogenized = blz.InxEndogenous;

    blz.Equation(blz.InxEquations) = this.Equation.Steady(blz.InxEquations);
    inxCopy = blz.InxEquations & cellfun('isempty', this.Equation.Steady(1, :));        
    blz.Equation(inxCopy) = this.Equation.Dynamic(inxCopy);

    blz.Gradient(:, inxMT) = this.Gradient.Steady(:, inxMT);
    blz.Gradient(:, inxCopy) = this.Gradient.Dynamic(:, inxCopy);
    blz.Incidence = this.Incidence.Steady;
    incid = across(blz.Incidence, 'Shift');
    blz.Assignment = this.Pairing.Assignment.Steady;
    blz.IsBlocks = opt.Blocks;
    logAllowed = { TYPE(1), TYPE(2), TYPE(4), TYPE(5) };

    blz.EquationsToExclude = find(inxLwP);
    blz.QuantitiesToExclude = find(inxPwL);


elseif strcmpi(kind, 'Period') || kind==solver.Method.PERIOD
    %
    % Period by period simulations
    % 
    blz = solver.blazer.Stacked(numEquations);
    blz.InxEndogenous = inxYX;
    blz.InxEquations = inxMT;
    blz.InxCanBeEndogenized = inxE;
    blz.InxCanBeExogenized = blz.InxEndogenous;

    blz.Equation(blz.InxEquations) = this.Equation.Dynamic(blz.InxEquations);
    blz.Incidence = selectShift(this.Incidence.Dynamic, 0);
    blz.Assignment = this.Pairing.Assignment.Dynamic;
    blz.IsBlocks = opt.Blocks;
    logAllowed = { TYPE(1), TYPE(2), TYPE(5) };


elseif strcmpi(kind, 'Stacked') || kind==solver.Method.STACKED
    %
    % Stacked time simulation
    %
    blz = solver.blazer.Stacked(numEquations);
    blz.InxEndogenous = inxYX;
    blz.InxEquations = inxMT;
    blz.InxCanBeEndogenized = inxE;
    blz.InxCanBeExogenized = blz.InxEndogenous;

    blz.Equation(blz.InxEquations) = this.Equation.Dynamic(blz.InxEquations);
    blz.Gradient(:, :) = [ ];
    blz.Incidence = this.Incidence.Dynamic;
    blz.Assignment = this.Pairing.Assignment.Dynamic;
    blz.IsBlocks = opt.Blocks;
    logAllowed = { TYPE(1), TYPE(2), TYPE(5) };

else
    throw(exception.Base('General:Internal', 'error'));
end

blz.Model.Quantity = this.Quantity;
blz.Model.Equation = this.Equation;

if isfield(opt, 'SuccessOnly')
    blz.SuccessOnly = opt.SuccessOnly;
end

% Change log-status of variables and/or parameters
if isfield(opt, 'Log') && ~isempty(opt.Log)
    blz.Model.Quantity = changeLogStatus(blz.Model.Quantity, true, opt.Log, logAllowed{:});
end
if isfield(opt, 'Unlog') && ~isempty(opt.Unlog)
    blz.Model.Quantity = changeLogStatus(blz.Model.Quantity, false, opt.Unlog, logAllowed{:});
end

if isequal(opt.Exogenize, @auto) || isequal(opt.Endogenize, @auto)
    [listExogenize, listEndogenize] = resolveAutoswap(this, kind, opt.Exogenize, opt.Endogenize);
else
    listExogenize = opt.Exogenize;
    listEndogenize = opt.Endogenize;
end

%
% Endogenize= option
%
if ischar(listEndogenize)
    listEndogenize = regexp(listEndogenize, '\w+', 'match');
elseif ~iscellstr(listEndogenize)
    listEndogenize = cellstr(listEndogenize);
end
listEndogenize = unique(listEndogenize);
if ~isempty(listEndogenize)
    outp = lookup(blz.Model.Quantity, listEndogenize);
    vecEndg = outp.PosName;
    endogenize(blz, vecEndg);
end

%
% Exogenize= option
%
if ischar(listExogenize)
    listExogenize = regexp(listExogenize, '\w+', 'match');
elseif ~iscellstr(listExogenize)
    listExogenize = cellstr(listExogenize);
end
listExogenize = unique(listExogenize);
if ~isempty(listExogenize)
    outp = lookup(blz.Model.Quantity, listExogenize);
    vecExg = outp.PosName;
    exogenize(blz, vecExg);
end

%
% Fix=, FixLevel=, FixChange= options
%
processFixOptions(blz, opt);

return

    function [inxPwL, inxLwP] = hereGetParameterLinks( )
        inxL = this.Equation.Type==TYPE(4);
        numL = nnz(inxL);
        inxPwL = false(1, numQuantities); % [^1]
        inxLwP = false(1, numEquations); % [^2]
        % [^1]: Index of parameters that occur on the LHS of a link
        % {^2]: Index of links that have a parameter on the LHS
        if isempty(this.Link)
            return
        end
        % LHS pointers to parameters; inactive links (LhsPtr<0) are
        % automatically excluded from the intersection
        [posPwL, pos] = intersect(this.Link.LhsPtr, find(inxP));
        if isempty(posPwL)
            return
        end
        inxPwL(posPwL) = true;
        % Index of links that have a parameter on the LHS
        inx = false(1, numL);
        inx(pos) = true;
        inxLwP(inxL) = inx;
    end%
end%


%
% Local Functions
%


function flag = locallyValidateKind(input)
    if isa(input, 'solver.Method')
        flag = true;
        return
    end
    if any(strcmpi(input, {'Steady', 'Stacked', 'Period'}))
        flag = true;
        return
    end
    flag = false;
end%


function flag = locallyValidateLogList(input)
    if isempty(input)
        flag = true;
        return
    end
    if isequal(input, @all)
        flag = true;
        return
    end
    if ischar(input) || iscellstr(input) || isa(input, 'string')
        flag = true;
        return
    end
    flag = false;
end%

