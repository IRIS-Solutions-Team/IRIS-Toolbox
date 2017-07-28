function [flag, varargout] = chksstate(this, varargin)
% chksstate  Check if equations hold for currently assigned steady-state values.
%
%
% Syntax
% =======
%
%     [Flag,List] = chksstate(M,...)
%     [Flag,Discr,List] = chksstate(M,...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object.
%
%
% Output arguments
% =================
%
% * `Flag` [ `true` | `false` ] - True if discrepancy between LHS and RHS
% is smaller than tolerance level in each equation.
%
% * `Discr` [ numeric ] - Discrepancies between LHS and RHS evaluated for
% each equation at two consecutive times, and returned as two column
% vectors.
%
% * `List` [ cellstr ] - List of equations in which the discrepancy between
% LHS and RHS is greater than `'tolerance='`.
%
%
% Options
% ========
%
% * `'Error='` [ *`true`* | `false` ] - Throw an error if one or more
% equations fail to hold up to tolerance level.
%
% * `'Eqtn='` [ `'Both'` | *`'Dynamic'`* | `'Steady'` ] - Check either
% dynamic equations or steady equations or both.
%
% * `'Warning='` [ *`true`* | `false` ] - Display warnings produced by this
% function.
%
%
% Description
% ============
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

[opt, varargin] = passvalopt('model.chksstate', varargin{:});
isSort = nargout>3;

% Pre-process options passed to `mychksstate`.
chksstateOpt = prepareChkSteady(this, 'verbose', varargin{:});

%--------------------------------------------------------------------------

% Refresh dynamic links.
if any(this.Link)
    this = refresh(this);
end

if opt.warning
    if any(strcmpi(chksstateOpt.Kind, {'dynamic', 'full'}))
        chksstateOpt.Kind = 'Dynamic';
        chkQty(this, Inf, 'parameters:dynamic', 'sstate', 'log');
    else
        chksstateOpt.Kind = 'Steady';
        chkQty(this, Inf, 'parameters:steady', 'sstate', 'log');
    end
end

nAlt = length(this);

% `dcy` is a matrix of discrepancies; it has two columns when dynamic
% equations are evaluated, or one column when steady equations are
% evaluated.
[flag, dcy, maxAbsDiscr, list] = mychksstate(this, Inf, chksstateOpt);

if any(~flag) && opt.error
    tmp = { };
    for i = find(~flag)
        for j = 1 : length(list{i})
            tmp{end+1} = exception.Base.alt2str(i); %#ok<AGROW>
            tmp{end+1} = list{i}{j}; %#ok<AGROW>
        end
    end
    if strcmpi(chksstateOpt.Kind, 'Dynamic')
        exc = exception.Base('Model:SteadyErrorInDynamic', 'error');
    else
        exc = exception.Base('Model:SteadyErrorInSteady', 'error');
    end
    throw(exc, tmp{:});
end

if isSort
    sortList = cell(1,nAlt);
    for iAlt = 1 : nAlt
        [~, ix] = sort(maxAbsDiscr(:,iAlt), 1, 'descend');
        dcy(:,:,iAlt) = dcy(ix,:,iAlt);
        sortList{iAlt} = this.Equation.Input(ix);
    end
end

if nAlt==1
    list = list{1};
    if isSort
        sortList = sortList{1};
    end
end

if nargout==2
    varargout{1} = list;
elseif nargout>2
    varargout{1} = dcy;
    varargout{2} = list;
    if isSort
        varargout{3} = sortList;
    end
end

end
