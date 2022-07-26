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
% -Copyright (c) 2007-2022 IRIS Solutions Team

function eoqDateCode = dateoq(dateCode)

    isDater = isa(dateCode, 'DateWrapper');
    dateCode = double(dateCode);
    sizeDateCode = size(dateCode);
    dateCode = reshape(dateCode, [], 1);

    if ~all(dater.getFrequency(dateCode)==frequency.Daily)
        exception.error(["Dater", "All input dates must be daily frequency dates." ]);
    end

    [y, m] = datevec(dateCode);
    m = 3*(ceil(m/3)-1) + 3;
    eoqDateCode = datenum([y, m, eomday(y, m)]);

    eoqDateCode = reshape(eoqDateCode, sizeDateCode);
    if isDater
        eoqDateCode = Dater(eoqDateCode);
    end

end%

