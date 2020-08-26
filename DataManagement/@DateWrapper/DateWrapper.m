classdef DateWrapper ...
    < double 

    methods
        function value = get(this, query)
            startsWith__ = @(x) startsWith(string(query), x, "ignoreCase", true);
            if startsWith__("FrequencyAsNum")
                value = dater.getFrequency(this);
            elseif startsWith__("Freq")
                value = DateWrapper.getFrequency(this);
            elseif startsWith__("Year")
                value = DateWrapper.getYear(this);
            else
                throw(exception.Base([
                    "DateWrapper:InvalidQuery"
                    "This is not a valid query into @DateWrapper/get: %s "
                ], "error"), query);
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
                freq = DateWrapper.getFrequency(this);
                firstFreq = freq(1);
                if all(firstFreq==freq(:))
                    frequencyDisplayName = char(firstFreq);
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
        
        
        function inx = ismember(this, that)
            inx = ismember(round(100*this), round(100*that));
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
                throw( exception.Base('DateWrapper:InvalidInputsIntoPlus', 'error') );
            end
            if ~all(double(a)==round(a)) && ~all(double(b)==round(b))
                throw( exception.Base('DateWrapper:InvalidInputsIntoPlus', 'error') );
            end
            x = double(a) + double(b);
            x = round(x*100)/100;
            try
                freq = dater.getFrequency(x);
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
                if ~all(dater.getFrequency(a(:))==dater.getFrequency(b(:)))
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
                serial = dater.getSerial(x);
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
            if isnan(from) || isnan(step) || isnan(to)
                this = DateWrapper.NaD( );
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
            serial = fromSerial : step : toSerial;
            serial = floor(serial);
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


        function this = getFirst(this)
            this = this(1);
        end%


        function this = getLast(this)
            this = this(end);
        end%


        function this = getIth(this, pos)
            this = this(pos);
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
            firstFrequency = dater.getFrequency(firstDate(:));
            lastFrequency = dater.getFrequency(lastDate(:));
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
            datetimeObj = dater.toMatlab(this, varargin{:});
        end%


        function [durationObj, halfDurationObj] = duration(this)
            frequency = DateWrapper.getFrequency(this);
            [durationObj, halfDurationObj] = duration(frequency);
        end%


        function isoString = toIsoString(varargin)
            isoString = dater.toIsoString(varargin{:});
        end%


        function defaultString = toDefaultString(varargin)
            defaultString = dater.toDefaultString(varargin{:});
        end%


        function datetimeObj = toMatlab(varargin)
            datetimeObj = dater.toMatlab(varargin{:});
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
        varargout = reportConsecutive(varargin)
        varargout = reportMissingPeriodsAndPages(varargin)
        varargout = resolveShift(varargin)


        function this = Inf( )
            this = DateWrapper(Inf);
        end%


        function this = NaD( )
            this = DateWrapper(NaN);
        end%


        function c = toCellstr(dateCode, varargin)
            c = dat2str(double(dateCode), varargin{:});
        end%


        function year = getYear(dateCode)
            year = dat2ypf(double(dateCode));
        end%


        function freq = getFrequency(dateCode)
            freq = Frequency(dater.getFrequency(dateCode));
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


        function checkMixedFrequency(varargin)
            if Frequency.sameFrequency(varargin{:})
                return
            end
            freq = reshape(varargin{1}, 1, [ ]);
            if nargin>=2
                freq = [freq, reshape(varargin{2}, 1, [ ])];
            end
            if nargin>=3
                context = varargin{3};
            else
                context = 'in this context';
            end
            cellstrFreq = Frequency.toCellstr(unique(freq, 'stable'));
            throw( exception.Base('Dates:MixedFrequency', 'error'), ...
                   context, cellstrFreq{:} ); %#ok<GTARG>
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
            freqLetter = iris.get('FreqLetters');
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
            match = regexpi(input, ['\d+[', freqLetter, ']\d*'], 'Once');
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
            refFreq = dater.getFrequency(ref);
            datesFreq = dater.getFrequency(dates);
            if ~all(datesFreq==refFreq)
                exception.error([
                    "DateWrapper:CannotRelativePositionForMixedFrequencies"
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
                        "DateWrapper:DateOutOfRange"
                        "These dates are out of %1: %s "
                    ], context, join(dater.toDefaultString(dates(inxOutRange))));
                end
            end
        end%


        function date = ii(input)
            date = DateWrapper(round(input));
        end%


        function dateString = toIMFString(date)
            dateString = dater.toDefaultString(date);
            freqLetters = iris.get('FreqLetters');
            % Replace yearly format 2020Y with 2020
            dateString = erase(dateString, freqLetters(1));
            % Replace half-yearly format 2020H1 with 2020B1
            dateString = replace(dateString, freqLetters(2), "B");
        end%


        function date = fromIMFString(freq, dateString)
            dateString = string(dateString);
            sizeDateString = size(dateString);
            switch freq
                case Frequency.YEARLY
                    date = yy(double(dateString));
                case Frequency.QUARTERLY
                    % Force the results to be 1-by-N-by-2
                    dateString = [reshape(dateString, 1, [ ]), "xxx-Qx"];
                    yp = split(dateString, "-Q");
                    yp(:, end, :) = [ ];
                    yp = double(yp);
                    date = qq(yp(:, :, 1), yp(:, :, 2));
                case Frequency.MONTHLY
                    dateString = [reshape(dateString, 1, [ ]), "xxx-xx"];
                    yp = split(dateString, "-");
                    yp(:, end, :) = [ ];
                    yp = double(yp);
                    date = mm(yp(:, :, 1), yp(:, :, 2));
            end
        end%


        function output = roundEqual(this, that)
            output = round(100*this)==round(100*that);
        end%




        function output = roundColon(from, varargin)
            if nargin==2
                to = varargin{1};
                step = 1;
            elseif nargin==3
                step = double(varargin{1});
                to = varargin{2};
            end
            convertToDateWrapper = isa(from, "DateWrapper") || isa(to, "DateWrapper");
            from = double(from);
            to = double(to);
            if ~isinf(from) && ~isinf(to)
                output = (round(100*from) : round(100*step) : round(100*to))/100;
            else
                if isinf(from)
                    from = -Inf;
                end
                if isinf(to)
                    to = Inf;
                end
                output = [from, to];
            end
            if convertToDateWrapper
                output = DateWrapper(output);
            end
        end%
    end
end
