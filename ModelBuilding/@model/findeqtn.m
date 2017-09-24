function varargout = findeqtn(this, varargin)
% findeqtn  Find equations by their labels.
%
% __Syntax__
%
%     [Eqtn, Eqtn, ...] = findeqtn(M, Label, Label, ...)
%
%
% __Input Arguments__
%
% * `m` [ model ] - Model object in which the equations will be searched
% for.
%
% * `Label` [ char | rexp ] - Equation labels that will be searched for,
% or rexp objects (regular expressions) against which the labels will be
% matched.
%
%
% __Output Arguments__
%
% * `Eqtn` [ char | cellstr ] - If `Label` is a text string, `Eqtn` is
% the first equation with the label `Label`; if `Label` is a rexp
% object (regular expression), `Eqtn` is a cell array of equations matched
% successfully against the regular expression.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

if nargin<2
    return
end

[ varargout{1:numel(varargin)} ] = find(this, 'eqn', varargin{:});

end
