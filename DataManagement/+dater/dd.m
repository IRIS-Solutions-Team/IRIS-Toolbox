% Type `web Dater/dd.md` for help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function dateCode = dd(varargin)

    if nargin==1 && validate.text(varargin{1})
        % From ISO string: dd("yyyy-mm-dd")
        dateCode = dater.fromIsoString(frequency.DAILY, string(varargin{1}));
        return
    end

    year = varargin{1};

    if nargin>=2
        month = varargin{2};
    else
        month = 1;
    end

    if nargin>=3
        day = varargin{3};
    else
        day = 1;
    end

    if validate.text(month)
        month = dater.monthFromString(month);
    end

    if any(month(:)<1 | month(:)>12)
        [year, month] = local_fixMonths(year, month);
    end

    if all(strcmpi(day, 'end'))
        day = eomday(year, month);
    end

    dateCode = datenum(year, month, day);

end%


function [year, month] = local_fixMonths(year, month)
    %(
    if numel(year)==1 && numel(month)>1
        year = repmat(year, size(month));
    elseif numel(month)==1 && numel(year)>1
        month = repmat(month, size(year));
    end
    year = year + ceil(month/12) - 1;
    month = mod(month-1, 12) + 1;
    %)
end%

