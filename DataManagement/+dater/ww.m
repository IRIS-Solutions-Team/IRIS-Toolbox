% Type `web Dater/ww.md` for help on this function
% 
% -[IrisToolbox] Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function dateCode = ww(varargin)

    if nargin==1 && validate.text(varargin{1})
        % From ISO string: ww("yyyy-mm-dd")
        dateCode = dater.fromIsoString(frequency.WEEKLY, string(varargin{1}));
        return
    end

    if nargin==3
        % * ww(year, month, day)
        if validate.text(varargin{2})
            varargin{2} = dater.monthFromString(varargin{2});
        end
        day = datenum(varargin{:});
        dateCode = numeric.day2ww(day);
        return
    end

    % * ww(year, week)
    % * ww(year, "end")
    % * ww(year)
    dateCode = dater.datecode(frequency.WEEKLY, varargin{:});

end%

