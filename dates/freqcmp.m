function flag = freqcmp(x, y)
% freqcmp  Compare date frequencies.
%
% Syntax
% =======
%
%     Flag = freqcmp(D1,D2)
%
%
% Input arguments
% ================
%
% * `D1`, `D2` [ numeric ] - IRIS serial date numbers.
%
%
% Output arguments
% =================
%
% * `Flag` [ `true` | `false` ] - True for dates of the same frequency.
%
%
% Description
% ============
%
%
% Example
% ========
%
%     d1 = qq(2000,1);
%     d2 = mm(2000,12);
%     d3 = qq(2010,4);
%     freqcmp(d1, d2)
%     ans =
%          0
%     freqcmp(d1, d3)
%     ans =
%          1
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

try
    y; %#ok<VUNUS>
catch
    if isempty(x) || all(isinf(x)) || isequal(x, @all)
        flag = true(size(x));
        return
    else
        y = x(1);
    end
end

%--------------------------------------------------------------------------

if isequal(x, @all) || isequal(y, @all) || isequal(x, Inf) || isequal(y, Inf)
    flag = true;
    return
end

if isa(x, 'tseries')
    x = startDate(x);
end

if isa(y, 'tseries')
    y = startDate(y);
end

ixXInf = isinf(x);
ixYInf = isinf(y);

fx = inf(size(x));
fy = inf(size(y));

fx(~ixXInf) = datfreq(x(~ixXInf));
fy(~ixYInf) = datfreq(y(~ixYInf));

flag = fx==fy | isinf(fx-fy);

end
