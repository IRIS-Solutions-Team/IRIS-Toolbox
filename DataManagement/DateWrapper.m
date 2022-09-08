classdef DateWrapper ...
    < double

    methods
        function value = get(this, query)
            startsWith__ = @(x) startsWith(string(query), x, "ignoreCase", true);
            if startsWith__("FrequencyAsNum")
                value = dater.getFrequency(this);
            elseif startsWith__("Freq")
                value = dater.getFrequency(this);
                value = Frequency(value);
            elseif startsWith__("Year")
                value = dater.getYear(this);
            else
                exception.error([
                    "Dater"
                    "This is not a valid query into DateWrapper/get: %s "
                ], query);
            end
        end%
    end


    methods
        function this = DateWrapper(varargin)
            this = this@double(varargin{:});
        end%


        function disp(this)
            sizeThis = size(this);
            sizeString = join(string(sizeThis), "x");
            isEmpty = any(sizeThis==0);
            if isEmpty
                frequencyDisplayName = "Empty";
            else
                freq = dater.getFrequency(this);
                firstFreq = freq(1);
                if all(firstFreq==freq(:))
                    frequencyDisplayName = char(Frequency(firstFreq));
                else
                    frequencyDisplayName = "Mixed Frequency";
                end
            end
            fprintf("  %s %s Date(s)\n", sizeString, frequencyDisplayName);
            if ~isEmpty
                textual.looseLine( );
                print = dater.toDefaultString(this);
                disp(categorical(print));
            end
            textual.looseLine( );
        end%


        function inx = ismember(varargin)
            inx = dater.ismember(varargin{:});
        end%


        function dt = not(this)
            dt = dater.toMatlab(this);
        end%


        function this = uplus(this)
        end%


        function this = uminus(this)
            inxInf = isinf(double(this));
            if ~all(inxInf)
                throw(exception.Base('DateWrapper:InvalidInputsIntoUminus', 'error'));
            end
            this = DateWrapper(-double(this));
        end%


        function this = plus(a, b)
            if isa(a, 'DateWrapper') && isa(b, 'DateWrapper')
                exception.error([
                    "Dater"
                    "Invalid date addition; add an integer to a date or a date to an integer."
                ]);
            end
            if ~all(double(a)==round(a)) && ~all(double(b)==round(b))
                exception.error([
                    "Dater"
                    "Invalid date addition; add an integer to a date or a date to an integer."
                ]);
            end
            x = double(a) + double(b);
            x = round(x*100)/100;
            this = DateWrapper(x);
        end%


        function output = minus(a, b)
            % Test if both inputs are dates; if so, return a numeric
            if (isa(a, 'DateWrapper') && isa(b, 'DateWrapper')) ...
                || (all(a(:)~=round(a(:))) && all(b(:)~=round(b(:))))
                if ~all(dater.getFrequency(a(:))==dater.getFrequency(b(:)))
                    exception.error([
                        "Dater"
                        "Invalid date subtraction; subtract an integer from a date "
                        "or two dates of the same frequency from each other."
                    ]);
                end
                output = floor(a) - floor(b);
                return
            end
            a = double(a);
            b = double(b);
            if ~all(a==round(a)) && ~all(b==round(b))
                throw( exception.Base('DateWrapper:InvalidInputsIntoMinus', 'error') );
            end
            x = double(a) - double(b);
            x = round(x*100)/100;
            try
                Frequency(dater.getFrequency(x));
            catch
                exception.error([
                    "Dater"
                    "Invalid date subtraction; subtract an integer from a date "
                    "or two dates of the same frequency from each other."
                ]);
            end
            output = DateWrapper(x);
        end%


        function this = colon(varargin)
            if nargin==2
                [from, to] = varargin{:};
                if isequal(from, -Inf) || isequal(to, Inf)
                    this = DateWrapper([from, to]);
                    return
                end
                step = 1;
            elseif nargin==3
                [from, step, to] = varargin{:};
            end
            if isnan(from) || isnan(step) || isnan(to)
                this = DateWrapper(NaN);
                return
            end
            if ~isnumeric(from) || ~isnumeric(to) ...
                || not(numel(from)==1) || not(numel(to)==1) ...
                || not(dater.getFrequency(from)==dater.getFrequency(to))
                throw(exception.Base('DateWrapper:InvalidStartEndInColon', 'error'));
            end
            if ~isnumeric(step) || numel(step)~=1 || step~=round(step)
                throw(exception.Base('DateWrapper:InvalidStepInColon', 'error'));
            end
            freq = dater.getFrequency(from);
            fromSerial = floor(from);
            toSerial = floor(to);
            serial = fromSerial : round(step) : toSerial;
            this = DateWrapper.fromSerial(freq, serial);
        end%


        function this = real(this)
            this = DateWrapper(real(double(this)));
        end%


        function this = min(varargin)
            minDouble = min@double(varargin{:});
            this = DateWrapper(minDouble);
        end%


        function this = max(varargin)
            maxDouble = max@double(varargin{:});
            this = DateWrapper(maxDouble);
        end%


        function datetimeObj = datetime(this, varargin)
            datetimeObj = dater.toMatlab(this, varargin{:});
        end%


        function [durationObj, halfDurationObj] = duration(this)
            frequency = getFrequency(this);
            [durationObj, halfDurationObj] = duration(frequency);
        end%


        function isoString = toIsoString(varargin)
            isoString = dater.toIsoString(varargin{:});
        end%


        function dateString = toDefaultString(varargin)
            dateString = dater.toDefaultString(varargin{:});
        end%


        function dateString = toString(varargin)
            dateString = dater.toString(varargin{:});
        end%


        function dateString = toChar(varargin)
            dateString = dater.toChar(varargin{:});
        end%


        function datetimeObj = toMatlab(varargin)
            datetimeObj = dater.toMatlab(varargin{:});
        end%


        function year = getYear(dateCode)
            year = dater.getYearPeriodFrequency(double(dateCode));
        end%


        function [year, period, freq] = getYearPeriodFrequency(dateCode)
            [year, period, freq] = dater.getYearPeriodFrequency(double(dateCode));
            freq = Frequency(freq);
        end%


        function freq = getFrequency(dateCode)
            freq = Frequency(dater.getFrequency(dateCode));
        end%


        function imfString = toImfString(this)
            imfString = dater.toImfString(this);
        end%
    end


    methods % == < > <= >=
        %(
        function flag = eq(d1, d2)
            flag = round(d1*100)==round(d2*100);
        end%


        function flag = lt(d1, d2)
            flag = round(d1*100)<round(d2*100);
        end%


        function flag = gt(d1, d2)
            flag = round(d1*100)>round(d2*100);
        end%


        function flag = le(d1, d2)
            flag = round(d1*100)<=round(d2*100);
        end%


        function flag = ge(d1, d2)
            flag = round(d1*100)>=round(d2*100);
        end%
        %)
    end


    methods (Hidden)
        function pos = positionOf(dates, start)
            dates = double(dates);
            if nargin<2
                refDate = min(dates(:));
            else
                refDate = start;
            end
            refDate = double(refDate);
            pos = round(dates - refDate + 1);
        end%


        function varargout = datestr(this, varargin)
            [varargout{1:nargout}] = datestr(double(this), varargin{:});
        end%


        function varargout = xline(this, varargin)
            [varargout{1:nargout}] = xline(dater.toMatlab(this), varargin{:});
        end%
    end


    methods (Static)
        function this = Inf( )
            this = DateWrapper(Inf);
        end%


        function this = NaD( )
            this = DateWrapper(NaN);
        end%


        function c = toCellstr(dateCode, varargin)
            c = dat2str(double(dateCode), varargin{:});
        end%


        function this = fromSerial(varargin)
            this = DateWrapper(dater.fromSerial(varargin{:}));
        end%


        function this = fromIsoString(varargin)
            this = DateWrapper(dater.fromIsoString(varargin{:}));
        end%


        function this = fromDatetime(varargin)
            this = DateWrapper(dater.fromMatlab(varargin{:}));
        end%


        function this = fromMatlab(varargin)
            this = DateWrapper(dater.fromMatlab(varargin{:}));
        end%


        function formats = chooseFormat(formats, freq, k)
            if nargin<3
                k = 1;
            elseif k>numel(formats)
                k = numel(formats);
            end

            if ischar(formats)
                return
            end

            if iscellstr(formats)
                formats = formats{k};
                return
            end

            if isa(formats, 'string')
                formats = formats(k);
                return
            end

            if ~isstruct(formats)
                throw( exception.Base('DateWrapper:InvalidDateFormat', 'error') );
            end

            switch freq
                case 0
                    formats = formats(k).ii;
                case 1
                    formats = formats(k).yy;
                case 2
                    formats = formats(k).hh;
                case 4
                    formats = formats(k).qq;
                case 6
                    formats = formats(k).bb;
                case 12
                    formats = formats(k).mm;
                case 52
                    formats = formats(k).ww;
                case 365
                    formats = formats(k).dd;
                otherwise
                    formats = '';
            end
        end%


        function pos = getRelativePosition(ref, dates, bounds, context)
            ref = double(ref);
            dates =  double(dates);
            refFreq = dater.getFrequency(ref);
            datesFreq = dater.getFrequency(dates);
            if ~all(datesFreq==refFreq)
                exception.error([
                    "Dater"
                    "Relative positions can be only calculated for dates of identical frequencies"
                ]);
            end
            refSerial = dater.getSerial(ref);
            datesSerial = dater.getSerial(dates);
            pos = round(datesSerial - refSerial + 1);
            % Check lower and upper bounds on the positions
            if nargin>=3 && ~isempty(bounds)
                inxOutRange = pos<bounds(1) | pos>bounds(2);
                if any(inxOutRange)
                    if nargin<4
                        context = "range";
                    end
                    exception.error([
                        "Dater"
                        "These dates are out of %1: %s "
                    ], context, join(dater.toDefaultString(dates(inxOutRange))));
                end
            end
        end%


        function date = ii(input)
            date = DateWrapper(round(input));
        end%


        function dateString = toIMFString(date)
            dateString = dater.toImfString(date);
        end%


        function date = fromIMFString(freq, dateString)
            dateString = string(dateString);
            sizeDateString = size(dateString);
            switch double(freq)
                case frequency.YEARLY
                    date = yy(double(dateString));
                case frequency.QUARTERLY
                    % Force the results to be 1-by-N-by-2
                    dateString = [reshape(dateString, 1, [ ]), "xxx-Qx"];
                    yp = split(dateString, "-Q");
                    yp(:, end, :) = [ ];
                    yp = double(yp);
                    date = qq(yp(:, :, 1), yp(:, :, 2));
                case frequency.MONTHLY
                    dateString = [reshape(dateString, 1, [ ]), "xxx-xx"];
                    yp = split(dateString, "-");
                    yp(:, end, :) = [ ];
                    yp = double(yp);
                    date = mm(yp(:, :, 1), yp(:, :, 2));
            end
        end%
    end
end
