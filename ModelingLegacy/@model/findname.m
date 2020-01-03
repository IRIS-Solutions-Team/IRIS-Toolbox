function varargout = findname(this, varargin)
% findname  Find names of variables, shocks, or parameters by their labels.
%
% Syntax
% =======
%
%     [found, found, ...] = findfound(m, search, search, ...)
%
%
% Input arguments
% ================
%
% * `m` [ model ] - Model object in which names will be searched for by
% their labels.
%
% * `search` [ char | rexp ] - Labels of variables, shocks, or parameters that
% will be searched for, or rexp objects (regular expressions) against which
% the labels will be matched.
%
%
% Output arguments
% =================
%
% * `found` [ char | cellstr ] - If `search` is a text string, `found` is
% the first model name found with the label `search`; if `search` is a
% rexp object (regular expression), `found` is a cell array of model names
% matched successfully against the regular expression.
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
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%--------------------------------------------------------------------------

if nargin<2
    return
end

numOfQueries = numel(varargin);
[~, varargout{1:numOfQueries}] = find(this, 'qty', varargin{:});

end
