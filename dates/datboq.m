function boqDateCode = datboq(dateCode)
% datboq  Beginning of quarter for the specified daily date
%
% Syntax
% =======
%
%     boqDateCode = datboq(dateCode)
%
%
% Input arguments
% ================
%
% * `dateCode` [ DateWrapper | double ] - Daily date.
%
%
% Output arguments
% =================
%
% * `boqDateCode` [ DateWrapper | double ] - Daily date for the first day of the
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
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

isDateWrapper = isa(dateCode, 'DateWrapper');
dateCode = double(dateCode);
sizeDateCode = size(dateCode);

[y, m] = datevec(dateCode(:));
m = 3*(ceil(m/3)-1) + 1;
boqDateCode = datenum([y, m, 1]);

boqDateCode = reshape(boqDateCode, sizeDateCode);
if isDateWrapper
    boqDateCode = DateWrapper(boqDateCode);
end

end%

