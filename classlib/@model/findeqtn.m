function varargout = findeqtn(this, varargin)
% findeqtn  Find equations by their labels.
%
%
% Syntax
% =======
%
%     [eqn, eqn, ...] = findeqtn(M, search, search, ...)
%
%
% Input arguments
% ================
%
% * `m` [ model ] - Model object in which the equations will be searched
% for.
%
% * `search` [ char | rexp ] - Equation label that will be searched for, or
% regular expression that will be matched against equation labels in model
% `m`.
%
%
% Output arguments
% =================
%
% * `eqn` [ char ] - First equation found with the label `search` (when
% `search is a character string) or cell array of equations (when `search`
% is a rexp object).
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

%--------------------------------------------------------------------------

if nargin<2
    return
end

[ varargout{1:numel(varargin)} ] = myfind(this, 'findeqtn', varargin{:});
for i = 1 : numel(varargout)
    if iscellstr(varargout{i})
        varargout{i} = varargout{i}.';
    end
end

end
