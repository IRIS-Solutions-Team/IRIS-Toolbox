function c = dat2charlist(d,varargin)
% dat2charlist  Convert dates to a comma-separated list.
%
% Syntax
% =======
%
%     C = dat2charlist(D,...)
%
% Input arguments
% ================
%
% * `D` [ numeric ] - IRIS serial date numbers that will be converted to a
% comma-separated list.
%
% Output arguments
% =================
%
% * `C` [ char ] - Text string with a comma-separated list of dates.
%
% Options
% ========
%
% See help on [`dat2str`](dates/dat2str) for options available.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%**************************************************************************

if isempty(d)
   c = '';
   return
end
c = dat2str(d,varargin{:});
c = sprintf('%s,',c{:});
c = c(1:end-1);

end
