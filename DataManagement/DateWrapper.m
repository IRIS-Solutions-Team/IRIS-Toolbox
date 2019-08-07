classdef DateWrapper < double 
    methods
        function this = DateWrapper(varargin)
            this = this@double(varargin{:});
        end%


        function disp(this)
            sizeOfThis = size(this);
            sizeString = sprintf('%gx', sizeOfThis);
            sizeString(end) = '';
            empty = any(sizeOfThis==0);
            if empty
                frequencyDisplayName = 'Empty';
            else
                freq = DateWrapper.getFrequency(this);
                firstOfFreq = freq(1);
                if all(firstOfFreq==freq(:))
                    frequencyDisplayName = char(firstOfFreq);
                else
                    frequencyDisplayName = 'Mixed Frequency';
                end
            end
            fprintf('  %s %s Date(s)\n', sizeString, frequencyDisplayName);
            if ~empty
                textfun.loosespace( )
                disp( DateWrapper.toCellOfChar(this) )
            end
            textfun.loosespace( )
        end%
        
        
        function dt = not(this)
            dt = DateWrapper.toDatetime(this);
        end%


        function this = uplus(this)
        end%


        function this = uminus(this)
            inxOfInf = isinf(double(this));
            if ~all(inxOfInf)
                throw( exception.Base('DateWrapper:InvalidInputsIntoUminus', 'error') );
            end
            this = DateWrapper(-double(this));
        end%


        function this = plus(a, b)
            if isa(a, 'DateWrapper') && isa(b, 'DateWrapper')
                throw( exception.Base('DateWrapper:InvalidInputsIntoPlus', 'error') );
            end
            if ~all(double(a)==round(a)) && ~all(double(b)==round(b))
                throw( exception.Base('DateWrapper:InvalidInputsIntoPlus', 'error') );
            end
            x = double(a) + double(b);
            x = round(x*100)/100;
            try
                freq = DateWrapper.getFrequencyAsNumeric(x);
            catch
                throw( exception.Base('DateWrapper:InvalidInputsIntoPlus', 'error') );
            end
            if isempty(x)
                this = DateWrapper.empty(size(x));
            else
                serial = floor(x);
                this = DateWrapper.fromSerial(freq(1), serial); 
            end
        end%
        
        
        function this = minus(a, b)
            if isa(a, 'DateWrapper') && isa(b, 'DateWrapper')
                if ~all(DateWrapper.getFrequencyAsNumeric(a(:))==DateWrapper.getFrequencyAsNumeric(b(:)))
                    throw( exception.Base('DateWrapper:InvalidInputsIntoMinus', 'error') );
                end
                this = floor(a) - floor(b);
                return
            end
            if ~all(double(a)==round(a)) && ~all(double(b)==round(b))
                throw( exception.Base('DateWrapper:InvalidInputsIntoMinus', 'error') );
            end
            x = double(a) - double(b);
            x = round(x*100)/100;
            try
                frequency = DateWrapper.getFrequency(x);
            catch
                throw( exception.Base('DateWrapper:InvalidInputsIntoMinus', 'error') );
            end
            if isempty(x)
                this = DateWrapper.empty(size(x));
            else
                serial = DateWrapper.getSerial(x);
                this = DateWrapper.fromSerial(frequency(1), serial); 
            end
        end%
        
        
        function this = colon(varargin)
            if nargin==2
                [from, to] = varargin{:};
                if isequal(from, -Inf) || isequal(to, Inf)
                    if ~isa(from, 'DateWrapper')
                        from = DateWrapper(from);
                    end
                    if ~isa(to, 'DateWrapper')
                        to = DateWrapper(to);
                    end
                    this = [from, to];
                    return
                end
                step = 1;
            elseif nargin==3
                [from, step, to] = varargin{:};
            end
            if ~isnumeric(from) || ~isnumeric(to) ...
                || numel(from)~=1 || numel(to)~=1 ...
                || DateWrapper.getFrequencyAsNumeric(from)~=DateWrapper.getFrequencyAsNumeric(to)
                throw( exception.Base('DateWrapper:InvalidStartEndInColon', 'error') );
            end
            if ~isnumeric(step) || numel(step)~=1 || step~=round(step)
                throw( exception.Base('DateWrapper:InvalidStepInColon', 'error') );
            end
            freq = DateWrapper.getFrequencyAsNumeric(from);
            fromSerial = floor(from);
            toSerial = floor(to);
            serial = fromSerial : step : toSerial;
            serial = floor(serial);
            this = DateWrapper.fromSerial(freq, serial);
        end%


        function this = real(this)
            this = DateWrapper(real(double(this)));
        end%

        
        function flag = eq(d1, d2)
            flag = round(d1*100)==round(d2*100);
        end%


        function this = min(varargin)
            minDouble = min@double(varargin{:});
            this = DateWrapper(minDouble);
        end%


        function this = max(varargin)
            maxDouble = max@double(varargin{:});
            this = DateWrapper(maxDouble);
        end%


        function this = getFirst(this)
            this = this(1);
        end%


        function this = getLast(this)
            this = this(end);
        end%


        function flag = isnad(this)
            flag = isequaln(double(this), NaN);
        end%


        function n = rnglen(varargin)
            if nargin==1
                firstDate = getFirst(varargin{1});
                lastDate = getLast(varargin{1});
            else
                firstDate = varargin{1};
                lastDate = varargin{2};
            end
            if ~isa(firstDate, 'DateWrapper') || ~isa(lastDate, 'DateWrapper')
                throw( exception.Base('DateWrapper:InvalidInputsIntoRnglen', 'error') );
            end
            firstFrequency = DateWrapper.getFrequencyAsNumeric(firstDate(:));
            lastFrequency = DateWrapper.getFrequencyAsNumeric(lastDate(:));
            if ~all(firstFrequency==lastFrequency)
                throw( exception.Base('DateWrapper:InvalidInputsIntoRnglen', 'error') );
            end
            n = floor(lastDate) - floor(firstDate) + 1;
        end%


        function this = addTo(this, c)
            if ~isa(this, 'DateWrapper') || ~isnumeric(c) || ~all(c==round(c))
                throw( exception.Base('DateWrapper:InvalidInputsIntoAddTo', 'error') );
            end
            this = DateWrapper(double(this) + c);
        end%
            

        function datetimeObj = datetime(this, varargin)
            datetimeObj = DateWrapper.toDatetime(this, varargin{:});
        end%


        function [durationObj, halfDurationObj] = duration(this)
            frequency = DateWrapper.getFrequency(this);
            [durationObj, halfDurationObj] = duration(frequency);
        end%
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
    end


    methods (Static)
        function this = Inf( )
            this = DateWrapper(Inf);
        end%


        function this = NaD( )
            this = DateWrapper(NaN);
        end%


        function c = toCellOfChar(dateCode, varargin)
            c = dat2str(double(dateCode), varargin{:});
        end%


        function decimal = getDecimal(dateCode)
            dateCode = double(dateCode);
            decimal = round(100*(dateCode - floor(dateCode)));
        end%


        function flag = validateDecimal(dateCode)
            decimal = DateWrapper.getDecimal(dateCode);
            flag = decimal==0 ...
                 | decimal==1 ...
                 | decimal==2 ...
                 | decimal==4 ...
                 | decimal==12 ...
                 | decimal==52 ;
        end%


        function frequency = getFrequencyAsNumeric(dateCode)
            frequency = DateWrapper.getDecimal(dateCode);
            inxOfZero = frequency==0;
            if any(inxOfZero)
                inxOfDaily = frequency==0 & floor(dateCode)>=Frequency.MIN_DAILY_SERIAL;
                frequency(inxOfDaily) = 365;
            end
        end%


        function frequency = getFrequency(dateCode)
            numericFrequency = DateWrapper.getFrequencyAsNumeric(dateCode);
            frequency = Frequency(numericFrequency);
        end%


        function serial = getSerial(input)
            serial = floor(double(input));
        end%


        function varargout = fromDouble(varargin)
            [varargout{1:nargout}] = DateWrapper.fromDateCode(varargin{:});            
        end%


        function [this, frequency, serial] = fromDateCode(x)
            frequency = DateWrapper.getFrequencyAsNumeric(x);
            serial = DateWrapper.getSerial(x);
            this = DateWrapper.fromSerial(frequency, serial);
        end%


        function this = fromSerial(varargin)
            dateCode = DateWrapper.getDateCodeFromSerial(varargin{:});
            this = DateWrapper(dateCode);
        end%


        function dateCode = getDateCodeFromSerial(freq, serial)
            serial0 = serial;
            serial = round(serial);
            inxRound = serial==serial0 | isnan(serial);
            if any(~inxRound)
                report = num2cell( serial0(~inxRound) );
                throw( exception.Base('Dates:NonIntegerSerialNumber', 'error'), ...
                       report{:} );
            end
            freq = double(freq);
            inxFreqCodes = freq~=Frequency.INTEGER & freq~=Frequency.DAILY;
            freqCode = zeros(size(freq));
            freqCode(inxFreqCodes) = double(freq(inxFreqCodes)) / 100;
            dateCode = serial + freqCode;
        end%


        function this = fromDatetime(frequency, dt)
            serial = ymd2serial(frequency, year(dt), month(dt), day(dt));
            this = DateWrapper.fromSerial(frequency, serial);
        end%


        function dateCode = fromDatetimeAsNumeric(freq, dt)
            serial = ymd2serial(freq, year(dt), month(dt), day(dt));
            dateCode = DateWrapper.getDateCodeFromSerial(freq, serial);
        end%


        function datetimeObj = toDatetime(input, varargin)
            frequency = DateWrapper.getFrequency(input);
            if ~all(frequency(1)==frequency(:))
                throw( exception.Base('DateWrapper:InvalidInputsIntoDatetime', 'error') )
            end
            datetimeObj = datetime(frequency(1), DateWrapper.getSerial(input), varargin{:});
        end%


        function checkMixedFrequency(freq1, freq2, context)
            if isempty(freq1)
                return
            end
            if isscalar(freq1) && (nargin<2 || isempty(freq2))
                return
            end
            if nargin==1 || isempty(freq2)
                if isscalar(freq1)
                    return
                end
                freq2 = freq1(2:end);
                freq1 = freq1(1);
            end
            if any(freq1~=freq2)
                if nargin<3
                    context = 'in this context';
                end
                freq = unique([freq1, freq2], 'stable');
                cellstrOfFreq = Frequency.toCellstr(freq);
                throw( exception.Base('Dates:MixedFrequency', 'error'), ...
                       context, cellstrOfFreq{:} ); %#ok<GTARG>
            end
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


        function flag = validateDateInput(input)
            freqLetters = iris.get('FreqLetters');
            if isa(input, 'DateWrapper')
                flag = true;
                return
            end
            if isa(input, 'double')
                try
                    DateWrapper.getFrequency(input);
                    flag = true;
                catch
                    flag = false;
                end
                return
            end
            if isequal(input, @all)
                flag = true;
                return
            end
            if ~(ischar(input) || isa(input, 'string')) || isempty(input)
                flag = false;
                return
            end
            input = strtrim(cellstr(input));
            match = regexpi(input, ['\d+[', freqLetters, ']\d*'], 'Once');
            flag = all(~cellfun('isempty', match));
        end%


        function flag = validateProperDateInput(input)
            if ~DateWrapper.validateDateInput(input)
                flag = false;
                return
            end
            if any(~isfinite(double(input)))
                flag = false;
                return
            end
            flag = true;
        end%
        

        function flag = validateRangeInput(input)
            if isequal(input, Inf) || isequal(input, @all)
                flag = true;
                return
            end
            if ischar(input) || isa(input, 'string')
                try
                    input = textinp2dat(input);
                catch
                    flag = false;
                    return
                end
            end
            if ~DateWrapper.validateDateInput(input)
                flag = false;
                return
            end
            if numel(input)==1
                flag = true;
                return
            end
            if numel(input)==2
                if (isinf(input(1)) || isinf(input(2)))
                    flag = true;
                    return
                elseif all(freqcmp(input))
                    flag = true;
                    return
                else
                    flag = false;
                    return
                end
            end
            if ~all(freqcmp(input))
                flag = false;
                return
            end
            if ~all(round(diff(input))==1)
                flag = false;
                return
            end
            flag = true;
        end


        function flag = validateProperRangeInput(input)
            if ischar(input) || isa(input, 'string')
                input = textinp2dat(input);
            end
            if ~DateWrapper.validateRangeInput(input)
                flag = false;
                return
            end
            if isequal(input, @all) || isempty(input) || any(isinf(input))
                flag = false;
                return
            end
            flag = true;
        end%


        function pos = getRelativePosition(ref, dates, bounds, context)
            ref = double(ref);
            dates =  double(dates);
            refFreq = DateWrapper.getFrequencyAsNumeric(ref);
            datesFreq = DateWrapper.getFrequencyAsNumeric(dates);
            if ~all(datesFreq==refFreq)
                THIS_ERROR= { 'DateWrapper:CannotRelativePositionForMixedFrequencies', ...
                              'Relative positions can be only calculated for dates of the same frequencies' };
                throw( excepion.Base(THIS_ERROR, 'error') );
            end
            refSerial = DateWrapper.getSerial(ref);
            datesSerial = DateWrapper.getSerial(dates);
            pos = round(datesSerial - refSerial + 1);
            % Check lower and upper bounds on the positions
            if nargin>=3 && ~isempty(bounds)
                inxOutOfRange = pos<bounds(1) | pos>bounds(2);
                if any(inxOutOfRange)
                    if nargin<4
                        context = 'range';
                    end
                    THIS_ERROR = { 'DateWrapper:DateOutOfRange'
                                   'This date is out of %1: %s ' };
                    temp = dat2str(dates(inxOutOfRange));
                    throw( exception.Base(THIS_ERROR, 'error'), ...
                           context, temp{:} );
                end
            end
        end%


        function date = ii(input)
            date = DateWrapper(round(input));
        end%
    end
end
