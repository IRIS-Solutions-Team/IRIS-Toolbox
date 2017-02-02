function [FF,AA,PDb] = qplot(QFile,D,Range,varargin)
% qplot  {Obsolete and scheduled for removal] Quick report.
%
% Obsolete IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

% ##### February 2015 OBSOLETE and scheduled for removal.
utils.warning('obsolete', ...
    ['Function qreport(...) and q-files are obsolete, ',...
    'and will be removed from IRIS in a future release. ', ...
    'Use dbplot(...) instead.']);

[FF,AA,PDb] = dbplot.dbplot(QFile,D,Range,varargin{:});

end
