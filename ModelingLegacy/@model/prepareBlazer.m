function blz = prepareBlazer(this, kind, varargin)
% prepareBlazer  Create Blazer object from dynamic or steady equations
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

TYPE = @int8;

persistent pp
if isempty(pp)
    pp = extend.InputParser('model.prepareBlazer');
    pp.KeepUnmatched = true;
    addRequired(pp, 'Model', @(x) isa(x, 'model'));
    addRequired(pp, 'Kind', @validateKind);
    addParameter(pp, 'Blocks', true, @(x) isequal(x, true) || isequal(x, false));
    addParameter(pp, 'Log', { }, @validateLogList);
    addParameter(pp, 'Unlog', { }, @validateLogList);
    addSwapOptions(pp);
end
parse(pp, this, kind, varargin{:});
opt = pp.Options;

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

    [inxP__, inxL__] = hereGetParameterLinks( );
    blz.InxEndogenous = inxYX | inxP__;
    blz.InxEquations = inxMT | inxL__ ;
    blz.InxCanBeEndogenized = inxP & ~inxP__;
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
    logStatusTypesAllowed = { TYPE(1), TYPE(2), TYPE(4), TYPE(5) };


elseif strcmpi(kind, 'Static') || kind==solver.Method.STATIC
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
    logStatusTypesAllowed = { TYPE(1), TYPE(2), TYPE(5) };


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
    logStatusTypesAllowed = { TYPE(1), TYPE(2), TYPE(5) };

else
    throw(exception.Base('General:Internal', 'error'));
end

blz.Model.Quantity = this.Quantity;
blz.Model.Equation = this.Equation;

% Change log-status of variables and/or parameters
if isfield(opt, 'Log') && ~isempty(opt.Log)
    blz.Model.Quantity = changeLogStatus(blz.Model.Quantity, true, opt.Log, logStatusTypesAllowed{:});
end
if isfield(opt, 'Unlog') && ~isempty(opt.Unlog)
    blz.Model.Quantity = changeLogStatus(blz.Model.Quantity, false, opt.Unlog, logStatusTypesAllowed{:});
end

if isequal(opt.Exogenize, @auto) || isequal(opt.Endogenize, @auto)
    [listExogenize, listEndogenize] = resolveAutoswap(this, kind, opt.Exogenize, opt.Endogenize);
else
    listExogenize = opt.Exogenize;
    listEndogenize = opt.Endogenize;
end

%
% Endogenize
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
% Exogenize
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

return

    function [inxP__, inxL__] = hereGetParameterLinks( )
        inxL = this.Equation.Type==TYPE(4);
        inxP__ = false(1, numQuantities);
        inxL__ = false(1, numEquations);
        if isempty(this.Link)
            return
        end
        % LHS pointers to parameters
        posP__ = intersect(this.Link.LhsPtrActive, find(inxP));
        if isempty(posP__)
            return
        end
        inxP__(posP__) = true;
        inxL__(inxL) = this.Link.InxActive;
    end%
end%


%
% Local Functions
%


function flag = validateKind(input)
    if isa(input, 'solver.Method')
        flag = true;
        return
    end
    if any(strcmpi(input, {'Steady', 'Stacked', 'Static', 'NoBlocks'}))
        flag = true;
        return
    end
    flag = false;
end%


function flag = validateLogList(input)
    if isempty(input)
        flag = true;
        return
    end
    if ischar(input) || iscellstr(input) || isa(input, 'string')
        flag = true;
        return
    end
    flag = false;
end%

