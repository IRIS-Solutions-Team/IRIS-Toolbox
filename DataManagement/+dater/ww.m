% Type `web Dater/ww.md` for help on this function
% 
% -[IrisToolbox] Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function dateCode = ww(year, varargin)

if nargin==3
    % * ww(year, month, day)
    if validate.text(varargin{1})
        varargin{1} = dater.monthFromString(varargin{1});
    end
    day = datenum(year, varargin{:});
    dateCode = numeric.day2ww(day);
else
    % * ww(year, week)
    % * ww(year, "end")
    % * ww(year)
    dateCode = dater.datecode(Frequency.WEEKLY, year, varargin{:});
end

end%

