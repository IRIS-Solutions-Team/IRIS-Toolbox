function dat = datbom(dat)
% datbom  Beginning of month for the specified daily date
%
% Syntax
% =======
%
%     bom = datbom(dat)
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
% * `bom` [ numeric ] - Daily serial date number for the first day of the
% same month as `dat`.
%
%
% Description
%============
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

if isa(dat, 'DateWrapper')
    outputClass = 'DateWrapper';
else
    outputClass = 'double';
end

[y, m] = datevec( double(dat) );
dat = datenum([y, m, 1]);

if strcmpi(outputClass, 'DateWrapper')
    dat = DateWrapper(dat);
end

end
