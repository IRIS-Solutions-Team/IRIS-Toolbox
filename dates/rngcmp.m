function flag = rngcmp(r1, r2)
% rngcmp  Compare two IRIS date ranges.
%
% Syntax
% =======
%
%     Flag = rngcmp(R1, R2)
%
% Input arguments
% ================
%
% * `R1`, `R2` [ numeric ] - Two IRIS date ranges that will be compared.
%
% Output arguments
% =================
%
% * `Flag` [ `true` | `false` ] - True if the two date ranges are the same.
%
% Description
% ============
%
% IRIS date ranges are distinct from plain vectors of dates: ranges are
% defined by their first and last dates only, and anything else is
% disregarded. Often, date ranges are context sensitive. In that case, you
% can use `-Inf` for the start date (meaning the earliest possible date in
% the given context) and `Inf` for the end date (meaning the latest
% possible date in the given context), or simply `Inf` for the whole range
% (meaning from the earliest possible date to the latest possible date in
% the given context).
%
% Example
% ========
%
%     r1 = qq(2010,1):qq(2020,4);
%     r2 = [qq(2010,1),qq(2020,4)];
%   
%     rngcmp(r1,r2)
%     ans =
%         1
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

% Parse required input arguments.
pp = inputParser( );
pp.addRequired('R1', @isnumeric);
pp.addRequired('R2', @isnumeric);
pp.parse(r1, r2);

%--------------------------------------------------------------------------

if isempty(r1) || isempty(r2)
    flag = isempty(r1) && isempty(r2);
    return
end

flag = datcmp(r1(1), r2(1)) && datcmp(r1(end), r2(end));

end
