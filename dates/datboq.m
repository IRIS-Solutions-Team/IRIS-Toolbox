function boq = datboq(dat)
% datboq  Beginning of quarter for the specified daily date
%
% Syntax
% =======
%
%     boq = datboq(dat)
%
%
% Input arguments
% ================
%
% * `dat` [ DateWrapper | double ] - Daily date.
%
%
% Output arguments
% =================
%
% * `boq` [ DateWrapper | double ] - Daily date for the first day of the
% same quarter as `D`.
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
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

if isa(dat, 'DateWrapper')
    outputClass = 'DateWrapper';
else
    outputClass = 'double';
end

[y, m] = datevec( double(dat) );
m = 3*(ceil(m/3)-1) + 1;
boq = datenum([y, m, 1]);

if strcmpi(outputClass, 'DateWrapper')
    dat = DateWrapper(dat);
end

end
