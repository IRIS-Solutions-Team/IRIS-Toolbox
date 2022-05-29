function month = per2month(period, freq, conversionMonth)
% per2month  Return month to represent a given period
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

if ischar(conversionMonth) || isa(conversionMonth, 'string')
    if strcmpi(conversionMonth, 'first')
        conversionMonth = 1;
    elseif strcmpi(conversionMonth, 'last')
        conversionMonth = 12 ./ freq;
    else
        conversionMonth = 1;
    end
end

month = (period-1).*12./freq + conversionMonth;

end%

