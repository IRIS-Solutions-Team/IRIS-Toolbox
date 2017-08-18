classdef Date
    properties (SetAccess=protected)
        Serial double = double.empty(0)
    end


    properties (SetAccess=immutable)
        Frequency Frequency = Frequency.NaF
    end


    methods
        function this = Date(varargin)
            if nargin==0
                return
            end
            if nargin==1 && isa(varargin{1}, 'Date')
                this = varargin{1};
                return
            end
            this.Frequency = varargin{1};
            if nargin>1
                this.Serial = serialize(this.Frequency, varargin{2:end});
            end
        end


        function serial = getSerial(this)
            serial = this.Serial;
        end


        function start = getStart(this)
            start = this;
            if numel(this.Serial)>1
                start.Serial = start.Serial(1);
            end
        end


        function end_ = getEnd(this)
            end_ = this;
            if numel(this.Serial)>1
                end_.Serial = end_.Serial(end);
            end
        end


        function disp(this)
            if this.Frequency==Frequency.INTEGER
                disp( round(this.Serial) );
            elseif isnan(this.Frequency)
                % Do nothing
            else
                disp( datetime(this.Frequency, this.Serial) );
            end
        end


        function c = toChar(this)
            if this.Frequency==Frequency.INTEGER
                c = int2str(this.Serial(:));
            elseif isnan(this.Frequency)
                c = 'NaF';
            else
                dt = datetime(this);
                c = char(dt(:));
            end
            c = strjust(c, 'right');
        end


        function display(this)
            [s, empty, sz] = textual.printSize(this.Serial);
            isHighDim = numel(sz)>2;
            isEmpty = any(sz==0);
            textual.looseLine( );
            if ~isHighDim
                fprintf('%s =\n', inputname(1));
                textual.looseLine( );
            end
            freqDisplayName = getDisplayName(this.Frequency);
            fprintf('  %s %s%s Date(s)\n', s, empty, freqDisplayName);
            if ~isHighDim || isEmpty
                textual.looseLine( );
            end
            disp(this);
        end


        function dt = datetime(this, varargin)
            dt = datetime(this.Frequency, this.Serial, varargin{:});
        end


        function varargout = size(this, varargin)
            [varargout{1:nargout}] = size(this.Serial, varargin{:});
        end


        function n = numel(this)
            n = numel(this.Serial);
        end


        function n = length(this)
            n = length(this.Serial);
        end


        function flag = isempty(this)
            flag = isempty(this.Serial);
        end


        function flag = isinf(this)
            flag = isinf(this.Serial);
        end


        function flag = isfinite(this)
            flag = isfinite(this.Serial);
        end

        
        function [pos, refDate] = positionOf(vecDate, start)
            vecDate.Serial = vecDate.Serial(:);
            if nargin<2
                refDate = min(vecDate);
            else
                refDate = start;
            end
            pos = round(vecDate.Serial - refDate.Serial + 1);
        end


        function k = end(this, varargin)
            temp = true(size(this.Serial));
            k = builtin('end', temp, varargin{:});
        end


        function flag = eq(a, b)
            flag = isequal(a, b);
        end


        function flag = gt(a, b)
            flag = validate(a, b) || isequal(a, Inf) || isequal(a, -Inf) || isequal(b, Inf) || isequal(b, -Inf);
            if ~flag
                return
            end
            if isa(a, 'Date')
                a = a.Serial;
            end
            if isa(b, 'Date')
                b = b.Serial;
            end
            flag = gt(a, b);
        end


        function flag = lt(a, b)
            flag = validate(a, b) || isequal(a, Inf) || isequal(a, -Inf) || isequal(b, Inf) || isequal(b, -Inf);
            if ~flag
                return
            end
            if isa(a, 'Date')
                a = a.Serial;
            end
            if isa(b, 'Date')
                b = b.Serial;
            end
            flag = lt(a, b);
        end


        function flag = ge(a, b)
            flag = validate(a, b) || isequal(a, Inf) || isequal(a, -Inf) || isequal(b, Inf) || isequal(b, -Inf);
            if ~flag
                return
            end
            if isa(a, 'Date')
                a = a.Serial;
            end
            if isa(b, 'Date')
                b = b.Serial;
            end
            flag = ge(a, b);
        end


        function flag = le(a, b)
            flag = validate(a, b) || isequal(a, Inf) || isequal(a, -Inf) || isequal(b, Inf) || isequal(b, -Inf);
            if ~flag
                return
            end
            if isa(a, 'Date')
                a = a.Serial;
            end
            if isa(b, 'Date')
                b = b.Serial;
            end
            flag = le(a, b);
        end


        function this = plus(a, b)
            if isnumeric(a) && all(round(a)==a)
                b.Serial = round(a + b.Serial);
                this = b;
            elseif isnumeric(b) && all(round(b)==b) 
                a.Serial = round(a.Serial + b);
                this = a;
            else
                error( ...
                    'Date:plus', ...
                    'Invalid input arguments to Date/plus.' ...
                );
            end
        end


        function outp = minus(a, b)
            if isa(a, 'Date') && isa(b, 'Date') ...
                && validate(a, b)
                outp = round(a.Serial - b.Serial);
            elseif isnumeric(b) && all(round(b)==b) 
                a.Serial = round(a.Serial - b);
                outp = a;
            else
                error( ...
                    'Date:minus', ...
                    'Invalid input arguments to Date/minus.' ...
                );
            end
        end


        function from = colon(from, varargin)
            if numel(varargin)==1
                step = 1;
                to = varargin{1};
            else
                step = varargin{1};
                to = varargin{2};
            end
            assert( ...
                numel(from)==1 && (isa(from, 'Date') || isequal(from, -Inf)), ...
                'Date:colon', ...
                'Date colon expressions must start with a Date or -Inf.' ...
                );
            assert( ...
                numel(to)==1 && (isa(to, 'Date') || isequal(to, Inf)), ...
                'Date:colon', ...
                'Date colon expressions must end with a Date or Inf.' ...
                );
            assert( ...
                numel(step)==1 && step==round(step), ...
                'Date:colon', ...
                'Date colon expressions must have scalar integer steps.' ...
            );
            assert( ...
                step==1 || (~isinf(from) && ~isinf(to)), ...
                'Date:colon', ...
                'Date colon expressions starting with -Inf or ending with Inf must have step=1.' ...
            );

            if isequal(from, -Inf) && isa(to, 'Date')
                from = to;
                from.Serial = [-Inf, from.Serial];
                return
            end
            if isequal(to, Inf) && isa(from, 'Date')
                from.Serial = [from.Serial, Inf];
                return
            end
            
            assert( ...
                validate(from, to), ...
                'Date:colon', ...
                'Date colon expressions must start and end with dates with the same frequency.' ...
            );
            from.Serial = round(from.Serial : step : to.Serial);
        end


        function this = fromFirstToLast(this)
            this.Serial = this.Serial(1) : this.Serial(end);
        end


        function flag = isnad(this)
            flag = isnaf(this.Frequency);
        end


        function flag = isnan(this)
            flag = isnad(this);
        end


        function this = max(varargin)
            if nargin==1
                this = varargin{1};
                this.Serial = round(max(this.Serial));
            elseif validate(varargin{:})
                this = varargin{1};
                serial = cellfun(@(x) x.Serial, varargin);
                this.Serial = round(max(serial));
            else
                error( ...
                    'Date:max', ...
                    'Invalid input arguments to Date/max.' ...
                );
            end
        end


        function this = min(varargin)
            if nargin==1
                this = varargin{1};
                this.Serial = round(min(this.Serial));
            elseif validate(varargin{:})
                this = varargin{1};
                serial = cellfun(@(x) x.Serial, varargin);
                this.Serial = round(min(serial));
            else
                error( ...
                    'Date:min', ...
                    'Invalid input arguments to Date/min.' ...
                );
            end
        end


        function [minDate, maxDate] = getMinMax(varargin)
            if nargin==1
                minDate = varargin{1};
                maxDate = varargin{1};
                serial = varargin{1}.Serial;
                minDate.Serial = round(min(serial));
                maxDate.Serial = round(max(serial));
            elseif validate(varargin{:})
                minDate = varargin{1};
                maxDate = varargin{1};
                serial = cellfun(@(x) x.Serial, varargin);
                minDate.Serial = round(min(serial));
                maxDate.Serial = round(max(serial));
            else
                error( ...
                    'Date:getMinMax', ...
                    'Invalid input arguments to Date/getMinMax.' ...
                );
            end
        end


        function out = subsref(this, s)
            switch s(1).type
            case '.'
                out = builtin('subsref', this, s);
            case '()'
                out = this;
                out.Serial = builtin('subsref', this.Serial, s);
            otherwise
                error( ...
                    'Date:subsref', ...
                    'Invalid subscripted reference to Date object.' ...
                );
            end
        end


        function this = getIth(this, i)
            this.Serial = this.Serial(i);
        end


        function this = getFirst(this)
            this.Serial = this.Serial(1);
        end


        function this = getLast(this)
            this.Serial = this.Serial(end);
        end


        function this = vec(this)
            this.Serial = this.Serial(:);
        end


        function n = numArgumentsFromSubscript(this, s, indexingContext)
            n = 1;
        end


        function this = subsasgn(this, s, a)
            switch s(1).type
            case '()'
                assert( ...
                    validate(this, a), ...
                    'Date:subsasgn', ...
                    'Invalid subscripted assignment to Date object.' ...
                );
                this.Serial = builtin('subsasgn', this.Serial, s, a.Serial);
            otherwise
                error( ...
                    'Date:subsasgn', ...
                    'Invalid subscripted assignment to Date object.' ...
                );
            end
        end


        function this = horzcat(varargin)
            this = cat(2, varargin{:});
        end


        function this = vertcat(varargin)
            this = cat(1, varargin{:});
        end


        function this = cat(dim, varargin)
            assert( ...
                validate(varargin{:}), ...
                'Date:cat', ...
                'Invalid concatenation of Date objects.' ...
            );
            serial = cellfun(@(x) x.Serial, varargin, 'UniformOutput', false);
            serial = cat(dim, serial{:});
            this = varargin{1};
            this.Serial = serial;
        end


        function this = repmat(this, varargin)
            this.Serial = repmat(this.Serial, varargin{:});
        end


        function this = ctranspose(this)
            this.Serial = ctranspose(this.Serial);
        end


        function this = transpose(this)
            this.Serial = transpose(this.Serial);
        end


        function this = permute(this, varargin)
            this.Serial = permute(this.Serial, varargin{:});
        end


        function this = ipermute(this, varargin)
            this.Serial = ipermute(this.Serial, varargin{1});
        end


        function flag = validate(this, varargin)
            flag = true;
            if ~isa(this, 'Date')
                flag = false;
                return
            end
            if isempty(varargin)
                return
            end
            frequency = this.Frequency;
            for i = 1 : length(varargin)
                if ~isa(varargin{i}, 'Date')
                    flag = false;
                    return
                end
                if varargin{i}.Frequency~=frequency
                    flag = false;
                    return
                end
            end
        end


        function freq = getFrequency(this)
            freq = this.Frequency;
        end


        function frequencyDisplayName = getFrequencyDisplayName(this)
            frequencyDisplayName = getDisplayName(this.Frequency);
        end


        function flag = isRange(this)
            if numel(this.Serial)<=1
                flag = true;
                return
            end
            if numel(this.Serial)==2 && this.Serial(1)<=this.Serial(2)
                flag = true;
                return
            end
            if all(diff(this.Serial)==1)
                flag = true;
                return
            end
            flag = false;
        end
    end




    methods (Hidden)
        function d = between(a, b)
            d = round(b.Serial - a.Serial + 1);
        end


        function this = addTo(this, c)
            this.Serial = round(this.Serial + c);
        end


        function this = emptyMe(this)
            this.Serial = this.Serial([ ], :);
        end


        function [highExtStart, highExtEnd, lowStart, lowEnd, ixHighInLowBins] = ...
                aggregateRange(highStart, highEnd, lowFreq)
            [highExtStartSerial, highExtEndSerial, lowStartSerial, lowEndSerial, ixHighInLowBins] = ...
                            aggregateRange(highStart.Frequency, highStart.Serial, highEnd.Serial, lowFreq);

            highExtStart = highStart;
            highExtStart.Serial = highExtStartSerial;
            highExtEnd = highEnd;
            highExtEnd.Serial = highExtEndSerial;

            lowStart = Date(lowFreq);
            lowStart.Serial = lowStartSerial;
            lowEnd = Date(lowFreq);
            lowEnd.Serial = lowEndSerial;
        end
    end




    methods (Static)
        function this = Y(varargin)
            this = Date(Frequency.YEARLY, varargin{:});
        end


        function this = H(varargin)
            this = Date(Frequency.HALFYEARLY, varargin{:});
        end


        function this = Q(varargin)
            this = Date(Frequency.QUARTERLY, varargin{:});
        end


        function this = M(varargin)
            this = Date(Frequency.MONTHLY, varargin{:});
        end


        function this = W(varargin)
            this = Date(Frequency.WEEKLY, varargin{:});
        end


        function this = D(varargin)
            this = Date(Frequency.DAILY, varargin{:});
        end


        function this = I(varargin)
            this = Date(Frequency.INTEGER, varargin{:});
        end


        function this = NaD(varargin)
            this = Date(Frequency.NaF);
        end


        function this = fromSerial(frequency, serial)
            this = Date(frequency);
            this.Serial = serial;
        end

            
        function this = empty(template, varargin)
            if isa(template, 'Date')
                template = template.Frequency;
            end
            this = Date(template);
            this.Serial = double.empty(varargin{:});
        end
    end
end
