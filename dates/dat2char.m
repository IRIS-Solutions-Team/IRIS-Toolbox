function c = dat2char(Dat,varargin)
% dat2char  Convert dates to character array.
%
% Syntax
% =======
%
%     C = dat2char(Dat,...)
%
% Input arguments
% ================
%
% * `Dat` [ numeric ] - IRIS serial date numbers that will be converted to
% character array.
%
% Output arguments
% =================
%
% * `C` [ char ] - Character array representing the input dates; each line
% of the array represents one date from `D`.
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
% We create a quarterly date using the function `qq`; this function returns
% an IRIS serial date number. We then use `dat2char` to print a
% humna-readable text representation of that date.
%
%     d = qq(2015,3)
%     d =
%        8.0620e+03
%     dat2char(d)
%     ans =
%     2015Q3
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

c = char( dat2str(Dat, varargin{:}) );

end%
