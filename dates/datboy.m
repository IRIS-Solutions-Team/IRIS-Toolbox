function boy = datboy(dat)
% datboy  Beginning of year for the specified daily date
%
% Syntax
% =======
%
%     boy = dateboy(dat)
%
%
% Input arguments
% ================
%
% * `dat` [ numeric ] - Daily serial date number.
%
%
% Output arguments
% =================
%
% * `boy` [ numeric ] - Daily serial date number for the first day of the
% same year as `dat`.
%
%
% Description
% ============
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

isDateWrapper = isa(dat, 'DateWrapper');

[y, ~] = datevec(double(dat));
boy = datenum([y, 1, 1]);

if isDateWrapper
    boy = DateWrapper(boy);
end

end%

