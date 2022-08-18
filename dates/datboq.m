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

function boqDateCode = datboq(dateCode)

    isDater = isa(dateCode, 'DateWrapper');
    dateCode = double(dateCode);
    sizeDateCode = size(dateCode);
    dateCode = reshape(dateCode, [], 1);

    if ~all(dater.getFrequency(dateCode)==frequency.Daily)
        exception.error(["Dater", "All input dates must be daily frequency dates." ]);
    end

    [y, m] = datevec(dateCode);
    m = 3*(ceil(m/3)-1) + 1;
    boqDateCode = datenum([y, m, 1]);

    boqDateCode = reshape(boqDateCode, sizeDateCode);
    if isDater
        boqDateCode = Dater(boqDateCode);
    end

end%

