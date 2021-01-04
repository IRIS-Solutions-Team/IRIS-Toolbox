% Type `web Dater/ww.md` for help on this function
% 
% -[IrisToolbox] Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function dateCode = ww(varargin)

if nargin==3
    % * ww(year, month, day)
    if validate.text(varargin{2})
        varargin{2} = dater.monthFromString(varargin{2});
    end
    day = datenum(varargin{:});
    dateCode = numeric.day2ww(day);
else
    % * ww(year, week)
    % * ww(year, "end")
    % * ww(year)
    dateCode = dater.datecode(Frequency.WEEKLY, varargin{:});
end

end%

