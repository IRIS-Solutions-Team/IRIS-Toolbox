classdef Frequency < double
    enumeration
        INTEGER     (  0) 
        YEARLY      (  1) 
        HALFYEARLY  (  2) 
        QUARTERLY   (  4) 
        MONTHLY     ( 12) 
        WEEKLY      ( 52) 
        DAILY       (365) 
        NaF         (NaN) 
    end


    methods
        function this = Frequency(varargin)
            this = this@double(varargin{:});
        end%


        function d = getCalendarDuration(this)
            switch this
                case Frequency.YEARLY
                    d = calendarDuration(1, 0, 0);
                case Frequency.HALFYEARLY
                    d = calendarDuration(0, 6, 0);
                case Frequency.QUARTERLY
                    d = calendarDuration(0, 3, 0);
                case Frequency.MONTHLY
                    d = calendarDuration(0, 1, 0);
                case Frequency.WEEKLY
                    d = calendarDuration(0, 0, 7);
                case Frequency.DAILY
                    d = calendarDuration(0, 0, 1);
                case Frequency.INTEGER
                    d = 1;
            end
        end%


        function d = getXLimMarginCalendarDuration(this)
            switch this
                case Frequency.YEARLY
                    d = calendarDuration(0, 6, 0);
                case Frequency.HALFYEARLY
                    d = calendarDuration(0, 3, 0);
                case Frequency.QUARTERLY
                    d = calendarDuration(0, 1, 15);
                case Frequency.MONTHLY
                    d = calendarDuration(0, 0, 15);
                case Frequency.WEEKLY
                    d = calendarDuration(0, 0, 3);
                case Frequency.DAILY
                    d = calendarDuration(0, 0, 1);
                case Frequency.INTEGER
                    d = 0.5;
            end
        end%


        function periodsPerYear = getPeriodsPerYear(this)
            switch this
                case {Frequency.YEARLY, Frequency.HALFYEARLY, ...
                        Frequency.QUARTERLY, Frequency.MONTHLY}
                    periodsPerYear = double(this);
                otherwise
                    periodsPerYear = NaN;
            end
        end


        function daysPerPeriods = getDaysPerPeriod(this)
            switch this
                case Frequency.WEEKLY
                    daysPerPeriods = 7;
                case Frequency.DAILY
                    daysPerPeriods = 1;
                otherwise
                    daysPerPeriods = NaN;
            end
        end


        function datetimeFormat = getDateTimeFormat(this)
            switch this
                case Frequency.YEARLY
                    datetimeFormat = 'uuuu''Y''';
                case {Frequency.HALFYEARLY, Frequency.MONTHLY}
                    datetimeFormat = 'uuuu''M''MM';
                case Frequency.QUARTERLY
                    datetimeFormat = 'uuuuQQQ';
                case {Frequency.WEEKLY, Frequency.DAILY}
                    datetimeFormat = 'uuuu-MM-dd';
                otherwise
                    datetimeFormat = char.empty(1, 0);
            end
        end


        function output = colon(a, b, varargin)
            if isa(a, 'Frequency')
                a = double(a);
            end
            if isa(b, 'Frequency')
                b = double(b);
            end
            if nargin>=3 && isa(varargin{1}, 'Frequency')
                varargin{1} = double(varargin{1});
            end
            output = colon(a, b, varargin{:});
        end


        function serial = serialize(this, varargin)
            switch this
                case Frequency.INTEGER
                    serial = round(varargin{1});
                case {Frequency.YEARLY, Frequency.HALFYEARLY, ...
                        Frequency.QUARTERLY, Frequency.MONTHLY}
                    periodsPerYear = getPeriodsPerYear(this);
                    year = round(varargin{1});
                    period = 1;
                    if length(varargin)>1
                        period = round(varargin{2});
                    end
                    serial = round(periodsPerYear*year + period - 1);
                case Frequency.WEEKLY
                    year = varargin{1};
                    month = varargin{2};
                    day = varargin{3};
                    dailySerial = floor(datenum(year, month, day));
                    sh = Frequency.shiftToThursday(dailySerial);
                    thursdayDailySerial = round(datenum(varargin{:}) + sh); % Serial of Thursday in the same week
                    fridayDailySerial = thursdayDailySerial + 1;
                    serial = round(fridayDailySerial/7); % Fridays are divisible by 7
                    serial = serial - 1; % Subtract 1 to have the first entire week in year 0 numbered 1
                case Frequency.DAILY
                    year = varargin{1};
                    month = varargin{2};
                    day = varargin{3};
                    dailySerial = floor(datenum(year, month, day));
                    serial = dailySerial;
                otherwise
                    serial = NaN;
            end
        end


        function varargout = deserialize(this, serial)
            switch this
                case Frequency.INTEGER
                    varargout = { round(serial) };
                case {Frequency.YEARLY, Frequency.HALFYEARLY, ...
                        Frequency.QUARTERLY, Frequency.MONTHLY}
                    periodsPerYear = getPeriodsPerYear(this);
                    year = floor(serial/periodsPerYear);
                    period = round(serial - periodsPerYear*year + 1);
                    varargout = { year, period };
                case Frequency.WEEKLY
                    dailySerial = round((serial + 1)*7 - 1); % 7-multiples of weekly serials are Fridays, return Thursday.
                    [year, month, day] = datevec(dailySerial);
                    varargout = { round(year), round(month), round(day) };
                case Frequency.DAILY
                    [year, month, day] = datevec(serial);
                    varargout = { round(year), round(month), round(day) };
                otherwise
                    varargout = { nan(size(serial)) };
            end
        end


        function [year, period] = serial2yp(this, serial)
            switch this
                case Frequency.INTEGER
                    year = nan(size(serial));
                    period = deserialize(this, serial);
                case {Frequency.YEARLY, Frequency.HALFYEARLY, ...
                        Frequency.QUARTERLY, Frequency.MONTHLY}
                    [year, period] = deserialize(this, serial);
                case Frequency.WEEKLY
                    year = deserialize(this, serial);
                    firstThursdayOfYear = Frequency.firstThursdayOfYear(year);
                    fwy = serialize(this, year, 1, firstThursdayOfYear);
                    period = round(serial - fwy + 1);
                case Frequency.DAILY
                    [year, month, day] = deserialize(this, serial);
                    startOfYear = floor(datenum(double(year), 1, 1));
                    period = round(serial - startOfYear + 1);
                otherwise
                    year = nan(size(serial));
                    period = nan(size(serial));
            end
        end


        function [year, month, day] = serial2ymd(this, serial, position)
            if nargin<3
                position = 'Start';
            end
            if ~any(strncmpi(position, {'s', 'm', 'e'}, 1))
                error( 'Frequency:serial2ymd', ...
                       'Invalid within-period position for Date conversion.' );
            end
            position = lower(position);
            switch this
            case Frequency.YEARLY
                year = deserialize(this, serial);
                switch lower(position(1))
                    case 's' % Start of period
                        month = 1;
                        day = 1;
                    case 'm' % Middle of period
                        month = 6;
                        day = 30;
                    case 'e' % End of period
                        month = 12;
                        day = 31;
                end
            case Frequency.HALFYEARLY
                [year, halfyear] = deserialize(this, serial);
                month = 6*(halfyear-1);
                switch lower(position(1))
                    case 's' % Start of period
                        month = month + 1;
                        day = 1;
                    case 'm' % Middle of period
                        month = month + 4;
                        day = 1;
                    case 'e' % End of period
                        month = month + 6;
                        day = eomday(year, month);
                end 
            case Frequency.QUARTERLY
                [year, quarter] = deserialize(this, serial);
                month = 3*(quarter-1);
                switch lower(position(1))
                    case 's' % Start of period
                        month = month + 1;
                        day = 1;
                    case 'm' % Middle of period
                        month = month + 2;
                        day = 15;
                    case 'e' % End of period
                        month = month + 3;
                        day = eomday(year, month);
                end
            case Frequency.MONTHLY
                [year, month] = deserialize(this, serial);
                switch lower(position(1))
                    case 's' % Start of period
                        day = 1;
                    case 'm' % Middle of period
                        day = 15;
                    case 'e' % End of period
                        day = eomday(year, month);
                end
            case Frequency.WEEKLY
                [year, month, day] = deserialize(this, serial);
                switch lower(position(1))
                    case 's' % Start of period
                        day = day - 3; % Return Monday
                    case 'm' % Middle of period
                        day = day + 0; % Return Thursday
                    case 'e' % End of period
                        day = day + 3; % Return Sunday
                end
            case Frequency.DAILY
                [year, month, day] = deserialize(this, serial);
            otherwise
                year = nan(size(serial));
                month = nan(size(serial));
                day = nan(size(serial));
            end
            year = round(year);
            month = round(month);
            day = round(day);
        end


        function serial = ymd2serial(this, year, month, day)
            switch this
                case Frequency.YEARLY
                    serial = serialize(this, year);
                case Frequency.HALFYEARLY
                    serial = serialize(this, year, month2period(this, month));
                case Frequency.QUARTERLY
                    serial = serialize(this, year, month2period(this, month));
                case Frequency.MONTHLY
                    serial = serialize(this, year, month);
                otherwise
                    serial = serialize(this, year, month, day);
            end
        end


        function period = month2period(this, month)
            period = nan(size(month));
            ixYearly = false(size(month));
            ixHalfYearly = false(size(month));
            ixQuarterly = false(size(month));
            ixMonthly = false(size(month));
            ixYearly(:) = this==Frequency.YEARLY;
            ixHalfYearly(:) = this==Frequency.HALFYEARLY;
            ixQuarterly(:) = this==Frequency.QUARTERLY;
            ixMonthly(:) = this==Frequency.MONTHLY;
            period(ixYearly) = 1;
            period(ixHalfYearly) = floor(double(month(ixHalfYearly)+5)/6);
            period(ixQuarterly) = floor(double(month(ixQuarterly)+2)/3);
            period(ixMonthly) = month(ixMonthly);
        end


        function datetimeObj = datetime(this, serial, varargin)
            if isequaln(this, Frequency.NaF)
                datetimeObj = NaT(size(serial));
                return
            end
            year = zeros(size(serial));
            month = zeros(size(serial));
            day = zeros(size(serial));
            indexInf = isinf(serial);
            [year(~indexInf), month(~indexInf), day(~indexInf)] = ...
                serial2ymd(this, serial(~indexInf), varargin{:});
            if this==Frequency.WEEKLY
                day(~indexInf) = day(~indexInf) - 3; % Return Monday, not Thursday, for display
            end
            year(indexInf) = serial(indexInf);
            datetimeObj = datetime(year, month, day);
            datetimeObj.Format = getDateTimeFormat(this);
        end


        function [durationObj, halfDurationObj] = duration(this)
            switch this
            case Frequency.YEARLY
                durationObj = calyears(1);
                halfDurationObj = calmonths(6);
            case Frequency.HALFYEARLY
                durationObj = calmonths(6);
                halfDurationObj = calmonths(3);
            case Frequency.QUARTERLY
                durationObj = calquarters(1);
                halfDurationObj = caldays(45);
            case Frequency.MONTHLY
                durationObj = calmonths(1);
                halfDurationObj = caldays(15);
            case Frequency.WEEKLY
                durationObj = calweeks(1);
                halfDurationObj = days(3.5);
            case Frequency.DAILY
                durationObj = caldays(1);
                halfDurationObj = days(0.5);
            otherwise
                durationObj = NaN;
                halfDurationObj = NaN;
            end
        end


        function flag = isnaf(this)
            flag = isnan(this);
        end


        function [highExtStartSerial, highExtEndSerial, lowStartSerial, lowEndSerial, ixHighInLowBins] = ...
                aggregateRange(highFreq, highStartSerial, highEndSerial, lowFreq)
            [year1, month1, day1] = serial2ymd(highFreq, highStartSerial, 'Start');
            lowStartSerial = ymd2serial(lowFreq, year1, month1, day1);
            [year2, month2, day2] = serial2ymd(lowFreq, lowStartSerial, 'Start');
            highExtStartSerial = ymd2serial(highFreq, year2, month2, day2);

            [year3, month3, day3] = serial2ymd(highFreq, highEndSerial, 'End');
            lowEndSerial = ymd2serial(lowFreq, year3, month3, day3);
            [year4, month4, day4] = serial2ymd(lowFreq, lowEndSerial, 'End');
            highExtEndSerial = ymd2serial(highFreq, year4, month4, day4);

            highExtRangeSerial = highExtStartSerial : highExtEndSerial;
            [year5, month5, day5] = serial2ymd(highFreq, highExtRangeSerial, 'middle');
            lowRangeSerial = ymd2serial(lowFreq, year5, month5, day5);

            uniqueLowRangeSerial = unique(lowRangeSerial, 'stable');
            ixHighInLowBins = cell(size(uniqueLowRangeSerial));
            for ithBin = 1 : numel(ixHighInLowBins)
                ixHighInLowBins{ithBin} = lowRangeSerial==uniqueLowRangeSerial(ithBin);
            end

            lowStartSerial = uniqueLowRangeSerial(1);
            lowEndSerial = uniqueLowRangeSerial(end);
        end%


        function c = cellstr(this)
            c = arrayfun(@(x) char(x), this, 'UniformOutput', false);
        end%
    end




    methods (Static)
        function c = toChar(freq)
            if ~isa(freq, 'Frequency')
                freq = Frequency(freq);
            end
            c = char(freq);
        end%


        function c = toCellstr(freq)
            if ~isa(freq, 'Frequency')
                freq = Frequency(freq);
            end
            c = cellstr(freq);
        end%


        function sh = shiftToThursday(dailySerial)
            sh = zeros(size(dailySerial));
            dayOfWeek = weekday(dailySerial);
            sh(dayOfWeek==1) = -3; % Sunday
            sh(dayOfWeek==2) = +3; % Monday
            sh(dayOfWeek==3) = +2; % Tuesday
            sh(dayOfWeek==4) = +1; % Wednesday
            sh(dayOfWeek==5) = +0; % Thursday
            sh(dayOfWeek==6) = -1; % Friday
            sh(dayOfWeek==7) = -2; % Saturday
        end%


        function day = firstThursdayOfYear(year)
            % Day of first Thursday in January.
            s = floor(datenum(double(year), 1, 1));
            temp = datenum(double(year), 1, 1);
            temp = weekday(temp);
            ixSun = temp==1;
            ixMon = temp==2;
            ixTue = temp==3;
            ixWed = temp==4;
            ixFri = temp==6;
            ixSat = temp==7;
            offset = zeros(size(temp));
            offset(ixSun) = 4;
            offset(ixMon) = 3;
            offset(ixTue) = 2;
            offset(ixWed) = 1;
            offset(ixFri) = 6;
            offset(ixSat) = 5;
            day = 1 + offset;
        end%


        function x = empty(varargin)
            x = repmat(Frequency.NaF, varargin{:});
        end%


        function this = fromString(string)
            if ~ischar(string) && ~(isa(string, 'string') && isscalar(string))
                throw( exception.Base('Frequency:InvalidConversionFromString', 'error') );
            end
            switch upper(char(string))
                case {'INTEGER', 'II', 'I'}
                    this = Frequency.INTEGER;
                case {'DAILY', 'DAY', 'DD', 'D'}
                    this = Frequency.DAILY;
                case {'WEEKLY', 'WEEK', 'WW', 'W'}
                    this = Frequency.WEEKLY;
                case {'MONTHLY', 'MONTH', 'MM', 'M'}
                    this = Frequency.MONTHLY;
                case {'QUARTERLY', 'QUARTER', 'QQ', 'Q'}
                    this = Frequency.QUARTERLY;
                case {'HALFYEARLY', 'HALFYEAR', 'SEMIANNUAL', 'SEMIANNUALLY', 'HH', 'H'}
                    this = Frequency.HALFYEARLY;
                case {'YEARLY', 'YEAR', 'ANNUAL', 'ANNUALLY', 'YY', 'Y'}
                    this = Frequency.YEARLY;
                case {'NAF', 'NAN', 'N'}
                    this = Frequency.NaF;
                otherwise
                    throw( exception.Base('Frequency:InvalidConversionFromString', 'error') );
            end
        end%


        function [flag, this] = validateFrequency(input)
            if isa(input, 'Frequency')
                flag = true;
                this = input;
                return
            end
            if isnumeric(input)
                this = Frequency.NaF;
                try
                    this = Frequency.fromNumeric(input);
                    flag = true;
                    return
                catch
                    flag = false;
                    return
                end
            elseif ischar(input) || (isa(input, 'string') && isscalar(input))
                this = Frequency.NaF;
                try
                    this = Frequency.fromString(input);
                    flag = true;
                    return
                catch
                    flag = false;
                    return
                end
            end
            flag = false;
        end%


        function [flag, this] = validateProperFrequency(input)
            [flag, this] = Frequency.validateFrequency(input);
            if flag
                flag = ~isempty(this) && ~isnan(this) && this~=Frequency.INTEGER;
            end
        end%


        function this = fromNumeric(input)
            try
                this = Frequency(input);
            catch
                throw( exception.Base('Frequency:InvalidConversionFromNumeric', 'error') );
            end
        end%
    end
end

