function varargout = qstyle(varargin)
% qstyle  [Obsolete function name and scheduled for removal] Graphics style.
%
% Obsolete IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

% ##### February 2015 OBSOLETE and scheduled for removal.
utils.warning('obsolete', ...
    ['Calls to qstyle(...) and qreport.qstyle(...) ', ...
    'are obsolete function names, ',...
    'and will be removed from IRIS in a future release. ', ...
    'Use grfun.style(...) instead.']);

[varargout{1:nargout}] = grfun.style(varargin{:});

end
