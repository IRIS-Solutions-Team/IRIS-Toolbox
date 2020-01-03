function eoqDateCode = dateoq(dateCode)
% dateoq  End of quarter for the specified daily date
%
% Syntax
% =======
%
%     eoqDateCode = dateoq(dateCode)
%
%
% Input arguments
% ================
%
% * `dateCode` [ numeric ] - Daily serial date number.
%
%
% Output arguments
% =================
%
% * `eoqDateCode` [ numeric ] - Daily serial date number for the last day of the
% same quarter as `dateCode`.
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
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

isDateWrapper = isa(dateCode, 'DateWrapper');
dateCode = double(dateCode);
sizeDateCode = size(dateCode);

[y, m] = datevec(dateCode(:));
m = 3*(ceil(m/3)-1) + 3;
eoqDateCode = datenum([y, m, eomday(y, m)]);

eoqDateCode = reshape(eoqDateCode, sizeDateCode);
if isDateWrapper
    eoqDateCode = DateWrapper(eoqDateCode);
end

end%
