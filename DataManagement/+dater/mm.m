function outputDate = mm(year, month)
% numeric.mm  IRIS date code for monthly dates
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

if nargin<2
    month = 1;
end

if ischar(month) || isa(month, 'string') || iscellstr(month)
    month = convertMonth(month);
end

outputDate = numeric.datecode(12, year, month);

end%


% 
% Local Functions
%


function month = convertMonth(monthText)
    ERROR_INVALID_MONTH = { 'Numeric:InvalidMonth'
                            'Cannot recognize this month: %s ' };
    monthText = cellstr(monthText);
    listOfMonths = { 'jan'
                     'feb'
                     'mar'
                     'apr'
                     'may'
                     'jun'
                     'jul'
                     'aug'
                     'sep'
                     'oct'
                     'nov'
                     'dec' };
    numOfMonths = numel(monthText);
    month = nan(size(monthText));
    inxOfValid = true(size(monthText));
    for i = 1 : numOfMonths
        if strcmpi(monthText{i}, 'end')
            month(i) = 12;
            continue
        end
        temp = find(strncmpi(monthText{i}, listOfMonths, 3));
        if numel(temp)~=1
            inxOfValid(i) = false;
            continue
        end
        month(i) = temp;
    end
    if any(~inxOfValid)
        throw( exception.Base(ERROR_INVALID_MONTH, 'error'), ...
               monthText{~inxOfValid} );
    end
end%

