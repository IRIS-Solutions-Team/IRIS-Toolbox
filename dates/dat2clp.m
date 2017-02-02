function c = dat2clp(dat, varargin)
% dat2clp  Convert dates to text and paste to system clipboard.
%
% Syntax
% =======
%
%     C = dat2clp(D,...)
%
%
% Input arguments
% ================
%
% * `D` [ numeric ] - IRIS serial date numbers that will be converted to
% character array and pasted to the system clipboard.
%
%
% Output arguments
% =================
%
% * `C` [ char ] - Character array representing the input dates pasted to
% the system clipboard; each line of the array represents one date from
% `D`.
%
%
% Options
% ========
%
% See help on [`dat2str`](dates/dat2str) for options available.
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

c = dat2str(dat, varargin{:});
c = sprintf('%s\n', c{:});
c(end) = '';
clipboard('copy', c);

end
