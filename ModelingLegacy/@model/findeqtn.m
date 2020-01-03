function varargout = findeqtn(this, varargin)
% findeqtn  Find equations by their labels.
%
% ## Syntax ##
%
%     [Eqtn, Eqtn, ...] = findeqtn(M, Label, Label, ...)
%
%
% ## Input Arguments ##
%
% * `m` [ model ] - Model object in which the equations will be searched
% for.
%
% * `Label` [ char | rexp ] - Equation labels that will be searched for,
% or rexp objects (regular expressions) against which the labels will be
% matched.
%
%
% ## Output Arguments ##
%
% * `Eqtn` [ char | cellstr ] - If `Label` is a text string, `Eqtn` is
% the first equation with the label `Label`; if `Label` is a rexp
% object (regular expression), `Eqtn` is a cell array of equations matched
% successfully against the regular expression.
%
%
% ## Description ##
%
%
% ## Example ##
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%--------------------------------------------------------------------------

if nargin<2
    return
end

numOfQueries = numel(varargin);
[~, varargout{1:numOfQueries} ] = find(this, 'eqn', varargin{:});

end
