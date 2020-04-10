function [flag, dcy, list, sortedList] = checkSteady(this, varargin)
% checkSteady  Check if equations hold for currently assigned steady-state values
%{
% Syntax
%--------------------------------------------------------------------------
%
%
%     [flag, discrepancy, list, sortedList] = checkSteady(model, ...)
%
%
% Input Arguments
%--------------------------------------------------------------------------
%
%
% __`model`__ [ Model ]
% > Model object with steady-state values assigned.
%
%
% Output Arguments
%--------------------------------------------------------------------------
%
%
% __`flag`__ [ `true` | `false` ] 
% > True if discrepancy between LHS and RHS is smaller than tolerance level
% in each equation.
%
%
% __`discrepancy`__ [ numeric ] 
% > Discrepancies between LHS and RHS evaluated for each equation at two
% consecutive times, and returned as two column vectors.
%
%
% __`list`__ [ cellstr ]
% > List of equations in which the discrepancy between LHS and RHS is
% greater than predefined tolerance, in the order of appearance in the
% `model`.
%
%
% __`sortedList`__ [ cellstr ]
% > List of equations in which the discrepancy between LHS and RHS is
% greater than predefined tolerance, sorted by the absolute discrepancy.
%
%
% Options
%--------------------------------------------------------------------------
%
%
% __`Error=true`__ [ `true` | `false` ]
% > Throw an error if one or more equations fail to hold up to tolerance
% level.
%
%
% __`EquationSwitch='Dynamic'`__ [ `'Both'` | `'Dynamic'` | `'Steady'` ]
% > Check either dynamic equations or steady equations or both.
%
%
% __`Warning=true`__ [ `true` | `false` ]  
% > Display warnings produced by this function.
%
%
% Description
%--------------------------------------------------------------------------
%
%
% Example
%--------------------------------------------------------------------------
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

TYPE = @int8;

persistent pp
if isempty(pp)
    pp = extend.InputParser('Model/checkSteady');
    pp.KeepUnmatched = true;
    addRequired(pp, 'model', @(x) isa(x, 'model'));

    addParameter(pp, 'Error', true, @validate.logicalScalar);
    addParameter(pp, 'Warning', true, @validate.logicalScalar);
end
parse(pp, this, varargin{:});
opt = pp.Options;
needsSort = nargout>3;

% Pre-process options passed to implementCheckSteady(~)
checkSteadyOpt = prepareCheckSteady(this, 'verbose', pp.UnmatchedInCell{:});

%--------------------------------------------------------------------------

% Refresh dynamic links
this = refresh(this);

if opt.Warning
    if any(strcmpi(checkSteadyOpt.EquationSwitch, {'Dynamic', 'Full'}))
        checkSteadyOpt.EquationSwitch = 'Dynamic';
        chkQty(this, Inf, 'parameters:dynamic', 'sstate', 'log');
    else
        checkSteadyOpt.EquationSwitch = 'Steady';
        chkQty(this, Inf, 'parameters:steady', 'sstate', 'log');
    end
end

nv = countVariants(this);

% `dcy` is a matrix of discrepancies; it has two columns when dynamic
% equations are evaluated, or one column when steady equations are
% evaluated.
[flag, dcy, maxAbsDiscr, list] = implementCheckSteady(this, Inf, checkSteadyOpt);

if any(~flag) && opt.Error
    tmp = { };
    for i = find(~flag)
        for j = 1 : length(list{i})
            tmp{end+1} = exception.Base.alt2str(i); %#ok<AGROW>
            tmp{end+1} = list{i}{j}; %#ok<AGROW>
        end
    end
    if strcmpi(checkSteadyOpt.EquationSwitch, 'Dynamic')
        exc = exception.Base('Model:SteadyErrorInDynamic', 'error');
    else
        exc = exception.Base('Model:SteadyErrorInSteady', 'error');
    end
    throw(exc, tmp{:});
end

if needsSort
    sortedList = cell(1, nv);
    for iAlt = 1 : nv
        [~, ix] = sort(maxAbsDiscr(:, iAlt), 1, 'descend');
        dcy(:, :, iAlt) = dcy(ix, :, iAlt);
        sortedList{iAlt} = this.Equation.Input(ix);
    end
end

if nv==1
    list = list{1};
    if needsSort
        sortedList = sortedList{1};
    end
end

end%

