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
        end


        function displayName = getDisplayName(this)
            if this==Frequency.HALFYEARLY
                displayName = 'Half-Yearly';
            elseif isnan(this)
                displayName = 'NaF';
            else
                displayName = char(this);
                displayName(2:end) = lower(displayName(2:end));
            end
        end


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


        function dtFormat = getDateTimeFormat(this)
            switch this
                case Frequency.YEARLY
                    dtFormat = 'uuuu''Y''';
                case {Frequency.HALFYEARLY, Frequency.MONTHLY}
                    dtFormat = 'uuuu''M''MM';
                case Frequency.QUARTERLY
                    dtFormat = 'uuuuQQQ';
                case {Frequency.WEEKLY, Frequency.DAILY}
                    dtFormat = 'uuuu-MM-dd';
                otherwise
                    dtFormat = char.empty(1, 0);
            end
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
                position = 'start';
            end
            assert( ...
                any(strncmpi(position, {'s', 'm', 'e'}, 1)), ...
                'Frequency:serial2ymd', ...
                'Invalid within-period position for Date conversion.' ...
            );
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


        function dateTimeObj = datetime(this, serial, varargin)
            year = zeros(size(serial));
            month = zeros(size(serial));
            day = zeros(size(serial));
            indexInf = isinf(serial);
            [year(~indexInf), month(~indexInf), day(~indexInf)] = serial2ymd(this, serial(~indexInf), varargin{:});
            if this==Frequency.WEEKLY
                day(~indexInf) = day(~indexInf) - 3; % Return Monday, not Thursday, for display
            end
            year(indexInf) = serial(indexInf);
            dateTimeObj = datetime(year, month, day);
            dateTimeObj.Format = getDateTimeFormat(this);
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
            [year1, month1, day1] = serial2ymd(highFreq, highStartSerial, 'start');
            lowStartSerial = ymd2serial(lowFreq, year1, month1, day1);
            [year2, month2, day2] = serial2ymd(lowFreq, lowStartSerial, 'start');
            highExtStartSerial = ymd2serial(highFreq, year2, month2, day2);

            [year3, month3, day3] = serial2ymd(highFreq, highEndSerial, 'end');
            lowEndSerial = ymd2serial(lowFreq, year3, month3, day3);
            [year4, month4, day4] = serial2ymd(lowFreq, lowEndSerial, 'end');
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
        end
    end




    methods (Static)
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
        end


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
        end


        function x = empty(varargin)
            x = repmat(Frequency.NaF, varargin{:});
        end


        function this = fromString(string)
            switch upper(char(string))
                case {'DAILY', 'DAY', 'DD'}
                    this = Frequency.DAILY;
                case {'WEEKLY', 'WEEK', 'WW'}
                    this = Frequency.WEEKLY;
                case {'MONTHLY', 'MONTH', 'MM'}
                    this = Frequency.MONTHLY;
                case {'QUARTERLY', 'QUARTER', 'QQ'}
                    this = Frequency.QUARTERLY;
                case {'HALFYEARLY', 'HALFYEAR', 'SEMIANNUAL', 'SEMIANNUALLY', 'HH'}
                    this = Frequency.HALFYEARLY;
                case {'YEARLY', 'YEAR', 'ANNUAL', 'ANNUALLY', 'YY'}
                    this = Frequency.YEARLY;
                otherwise
                    this = Frequency.NaF;
            end
        end
    end
end

