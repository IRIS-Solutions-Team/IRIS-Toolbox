classdef DateWrapper < double 
    methods
        function this = DateWrapper(varargin)
            this = this@double(varargin{:});
        end


        function frequency = getFrequency(this)
            frequency = DateWrapper.getFrequencyFromNumeric(double(this));
        end


        function serial = getSerial(this)
            serial = DateWrapper.getSerialFromNumeric(double(this));
        end
        
        
        function disp(this)
            sizeString = sprintf('%gx', size(this));
            sizeString(end) = '';
            freq = getFrequency(this);
            if isempty(freq)
                frequencyDisplayName = 'Empty';
            elseif all(freq(1)==freq(:))
                frequencyDisplayName = getDisplayName(freq(1));
            else
                frequencyDisplayName = 'Mixed Frequency';
            end
            fprintf('  %s %s Date(s)\n', sizeString, frequencyDisplayName);
            textfun.loosespace( );
            x = dat2str(this);
            disp(x);
            textfun.loosespace( );
        end
        
        
        function this = uplus(this)
        end


        function this = uminus(this)
            indexOfInf = isinf(double(this));
            assert( ...
                all(indexOfInf), ...
                'DateWrapper:uminus', ...
                'DateWrapper/uminus can only be applied to Inf or -Inf.' ...
            );
            this = DateWrapper(-double(this));
        end


        function this = plus(a, b)
            assert( ...
                ~isa(a, 'DateWrapper') || ~isa(b, 'DateWrapper'), ...
                'DateWrapper:plus', ...
                'Invalid arguments into a DateWrapper plus expression.' ...
            );
            assert( ...
                all(double(a)==round(a)) || all(double(b)==round(b)), ...
                'DateWrapper:plus', ...
                'Invalid arguments into a DateWrapper plus expression.' ...
            );
            x = double(a) + double(b);
            x = round(x*100)/100;
            try
                frequency = DateWrapper.getFrequencyFromNumeric(x);
            catch
                frequency = NaN;
            end
            assert( ...
                isempty(frequency) || all(frequency(1)==frequency(:)), ...
                'DateWrapper:plus', ...
                'Invalid arguments into a DateWrapper plus expression.' ...
            );
            if isempty(x)
                this = DateWrapper.empty(size(x));
            else
                serial = floor(x);
                this = DateWrapper.fromSerial(frequency(1), serial); 
            end
        end
        
        
        function this = minus(a, b)
            if isa(a, 'DateWrapper') && isa(b, 'DateWrapper')
                assert( ...
                    all(DateWrapper.getFrequencyFromNumeric(a(:))==DateWrapper.getFrequencyFromNumeric(b(:))), ...
                    'DateWrapper:minus', ...
                    'Invalid arguments into a DateWrapper minus expression.' ...
                );
                this = floor(a) - floor(b);
                return
            end
            assert( ...
                all(double(a)==round(a)) || all(double(b)==round(b)), ...
                'DateWrapper:minus', ...
                'Invalid arguments into a DateWrapper minus expression.' ...
            );
            x = double(a) - double(b);
            x = round(x*100)/100;
            try
                frequency = DateWrapper.getFrequencyFromNumeric(x);
            catch
                frequency = NaN;
            end
            assert( ...
                isempty(frequency) || all(frequency(1)==frequency(:)), ...
                'DateWrapper:minus', ...
                'Invalid arguments into a DateWrapper minus expression.' ...
            );
            if isempty(x)
                this = DateWrapper.empty(size(x));
            else
                serial = DateWrapper.getSerialFromNumeric(x);
                this = DateWrapper.fromSerial(frequency(1), serial); 
            end
        end
        
        
        function this = colon(varargin)
            if nargin==2
                [from, to] = varargin{:};
                step = 1;
            elseif nargin==3
                [from, step, to] = varargin{:};
            end
            assert( ...
                isnumeric(from) && isnumeric(to) ...
                && numel(from)==1 && numel(to)==1 ...
                && DateWrapper.getFrequencyFromNumeric(from)==DateWrapper.getFrequencyFromNumeric(to), ...
                'DateWrapper:colon', ...
                'Start and end dates in a DateWrapper colon expression must be scalar dates of the same frequencies.' ...
            );
            assert( ...
                isnumeric(step) && numel(step)==1 && step==round(step), ...
                'DateWrapper:colon', ...
                'Step in a DateWrapper colon expression must be a scalar integer.' ...
            );
            frequency = DateWrapper.getFrequencyFromNumeric(from);
            fromSerial = floor(from);
            toSerial = floor(to);
            serial = fromSerial : step : toSerial;
            this = DateWrapper.fromSerial(frequency, serial);
        end


        function this = real(this)
            this = DateWrapper(real(double(this)));
        end

        
        function flag = eq(d1, d2)
            flag = round(d1*100)==round(d2*100);
        end


        function this = min(varargin)
            minDouble = min@double(varargin{:});
            this = DateWrapper(minDouble);
        end


        function this = max(varargin)
            maxDouble = max@double(varargin{:});
            this = DateWrapper(maxDouble);
        end


        function this = getFirst(this)
            this = this(1);
        end


        function this = getLast(this)
            this = this(end);
        end


        function flag = isnad(this)
            flag = isequaln(double(this), NaN);
        end


        function n = rnglen(varargin)
            if nargin==1
                firstDate = getFirst(varargin{1});
                lastDate = getLast(varargin{1});
            else
                firstDate = varargin{1};
                lastDate = varargin{2};
            end
            assert( ...
                isa(firstDate, 'DateWrapper') && isa(lastDate, 'DateWrapper'), ...
                'DateWrapper:rnglen', ...
                'Input arguments into DateWrapper/rnglen must both be scalar DateWrapper objects.' ...
            );
            firstFrequency = DateWrapper.getNumericFrequencyFromNumeric(firstDate(:));
            lastFrequency = DateWrapper.getNumericFrequencyFromNumeric(lastDate(:));
            assert( ...
                all(firstFrequency==lastFrequency), ...
                'DateWrapper:rnglen', ...
                'All input arguments into DateWrapper/rnglen must be of the same date frequency' ...
            );
            n = floor(lastDate) - floor(firstDate) + 1;
        end


        function this = addTo(this, c)
            assert( ...
                isa(this, 'DateWrapper') && isnumeric(c) && all(c==round(c)), ...
                'DateWrapper:addTo', ...
                'Invalid input arguments into DateWrapper/addTo.' ...
            );
            this = DateWrapper(double(this) + c);
        end
            

        function datetimeObj = datetime(this, varargin)
            frequency = DateWrapper.getFrequencyFromNumeric(this);
            assert( ...
                all(frequency(1)==frequency(:)), ...
                'DateWrapper:datetime', ...
                'All DateWrappers in datetime( ) conversion must be of the same date frequency.' ...
            );
            datetimeObj = datetime(frequency(1), getSerial(this), varargin{:});
        end


        function [durationObj, halfDurationObj] = duration(this)
            frequency = DateWrapper.getFrequencyFromNumeric(this);
            [durationObj, halfDurationObj] = duration(frequency);
        end
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
        end
    end


    methods (Static)
        function this = Inf( )
            this = DateWrapper(Inf);
        end


        function this = NaD( )
            this = DateWrapper(NaN);
        end


        function frequency = getNumericFrequencyFromNumeric(dat)
            MIN_DAILY_SERIAL = 365244;
            dat = double(dat);
            frequency = round(100*(dat - floor(dat)));
            indexDaily = frequency==0 & dat>=MIN_DAILY_SERIAL;
            frequency(indexDaily) = 365;
        end


        function frequency = getFrequencyFromNumeric(dat)
            frequency = Frequency( DateWrapper.getNumericFrequencyFromNumeric(dat) );
        end


        function serial = getSerialFromNumeric(dat)
            serial = floor(dat);
        end


        function [this, frequency, serial] = fromDouble(x)
            frequency = DateWrapper.getNumericFrequencyFromNumeric(x);
            serial = DateWrapper.getSerialFromNumeric(x);
            this = DateWrapper.fromSerial(frequency, serial);
        end


        function this = fromSerial(frequency, serial)
            ixAddFrequency = frequency~=Frequency.INTEGER & frequency~=Frequency.DAILY;
            addFrequency = zeros(size(frequency));
            addFrequency(ixAddFrequency) = double(frequency(ixAddFrequency))/100;
            this = DateWrapper(serial + addFrequency);
        end


        function checkMixedFrequency(freq)
            if isempty(freq)
                return
            end
            if any(freq(1)~=freq)
                freq = unique(freq, 'stable');
                lsFreq = DateWrapper.printFreqName(freq);
                temp = sprintf('%s x ', lsFreq{:});
                temp(end-2:end) = '';
                throw( ...
                    exception.Base('DateWrapper:MixedFrequency', 'error'), ...
                    temp ...
                ); %#ok<GTARG>
            end
        end
        
        
        function prt = printFreqName(f)
            freqName = iris.get('FreqNames');
            if isnumeric(f)
                f = num2cell(f);
            end
            prt = values(freqName, f);
        end


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
            throw( ...
                exception.Base('DateWrapper:InvalidDateFormat', 'error') ...
            );
        end

        switch freq
            case 0
                formats = formats(k).integer;
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

        end


        function flag = validateDateInput(input)
            if isa(input, 'DateWrapper')
                flag = true;
                return
            end
            if isa(input, 'double')
                flag = true;
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
            flag = isstrprop(input(1), 'digit') && any(isstrprop(input, 'alpha')) ...
                && ~any(input=='=');
        end


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
        end
    end


    methods (Static)
        function date = ii(input)
            date = DateWrapper(round(input));
        end
    end
end
