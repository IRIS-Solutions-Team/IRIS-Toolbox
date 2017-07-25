function varargout = findeqtn(this, varargin)
% findeqtn  Find equations by their labels.
%
% Syntax
% =======
%
%     [found, found, ...] = findeqtn(M, search, search, ...)
%
%
% Input arguments
% ================
%
% * `m` [ model ] - Model object in which the equations will be searched
% for.
%
% * `search` [ char | rexp ] - Equation labels that will be searched for,
% or rexp objects (regular expressions) against which the labels will be
% matched.
%
%
% Output arguments
% =================
%
% * `found` [ char | cellstr ] - If `search` is a text string, `found` is
% the first equation found with the label `search`; if `search` is a rexp
% object (regular expression), `found` is a cell array of equations matched
% successfully against the regular expression.
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

[ varargout{1:numel(varargin)} ] = find(this, 'eqn', varargin{:});

end
