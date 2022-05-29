function flag = datcmp(dat1, dat2)
% datcmp  Compare two IRIS serial date numbers.
%
% Syntax
% =======
%
%     flag = datcmp(dat1, dat2)
%
%
% Input arguments
% ================
%
% * `dat1`, `dat2` [ numeric ] - IRIS serial date numbers or vectors.
%
%
% Output arguments
% =================
%
% * `flag` [ `true` | `false` ] - True for numbers that represent the same
% date.
%
%
% Description
% ============
%
% The two date vectors must either be the same lengths, or one of them must
% be scalar.
%
% Use this function instead of the plain comparison operator, `==`, to
% compare dates. The plain comparision can sometimes give false results
% because of round-off errors.
%
%
% Example
% ========
%
%     d1 = qq(2010, 1);
%     d2 = qq(2009, 1):qq(2010, 4);
%     datcmp(d1, d2)
%     ans =
%         0     0     0     0     1     0     0     0

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

dat1 = double(dat1);
dat2 = double(dat2);
flag = round(100*dat1)==round(100*dat2) | (isinf(dat1) & isinf(dat2));

end%

