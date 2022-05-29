function [D,E] = datdiff(D1,D2)
% datdiff  Number of periods between two dates with check for date frequency.
%
% Syntax
% =======
%
%     D = datdiff(D1,D2)
%
% Input arguments
% ================
%
% * `D1`, `D2` [ numeric ] - IRIS dates of vectors of IRIS dates.
%
% Output arguments
% =================
%
% * `D` [ numeric ] - Number of periods between `D1` and `D2`, positive for
% `D1` greater than `D2`, negative for `D1` smaller than `D2`, or NaN for
% dates of different frequencies.
%
% Description
% ============
%
% Example
% ========
%
%     d1 = mm(2010,12);
%     d2 = mm(2011,12);
%   
%     datdiff(d1,d2)
%     ans =
%        -12
%   
%     datdiff(d2,d1)
%     ans =
%         12
%   
%     d3 = yy(2011);
%     datdiff(d1,d3)
%     ans =
%        NaN
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

D = nan(size(D1));
inx = freqcmp(D1,D2);
D(inx) = floor(D1(inx)) - floor(D2(inx));

end
