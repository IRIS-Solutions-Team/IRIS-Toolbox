classdef tableobj < report.tabularobj
    
    methods
        
        function this = tableobj(varargin)
            isnumericscalar = @(x) isnumeric(x) && isscalar(x);
            this = this@report.tabularobj(varargin{:});
            this.childof = {'report', 'align'};
            this.default = [this.default, { ...
                'colhighlight, highlight', [ ], @isnumeric, true, ...
                'colstruct, columnstruct', struct([ ]), ...
                @(x) isempty(x) || report.genericobj.validatecolstruct(x), ...
                true, ...
                'datejustify', [ ], ...
                @(x) isempty(x) || (ischar(x) && any(strncmpi(x, {'c', 'l', 'r'}, 1))), ...
                true, ...
                'colfootnote', { }, @(x) isempty(x) ...
                || (iscell(x) && all(cellfun(isnumericscalar, x(1:2:end))) && iscellstr(x(2:2:end))), ...
                true, ...
                'headlinejust', 'c', ...
                @(x) ischar(x) && any(strncmp(x, {'c', 'l', 'r'}, 1)), ...
                true, ...
                'range', [ ], @isnumeric, true, ...
                'separator', '\medskip\par', @ischar, true, ...
                'typeface', '', @ischar, false, ...
                'vlineafter, vline', [ ], @isnumeric, true, ...
                'vlinebefore', [ ], @isnumeric, true, ...
                ...
                ... Date format options
                ...---------------------
                'dateformat', @auto, @iris.Configuration.validateDateFormat, true, ...
                'months', @auto, @iris.Configuration.validateMonths, true, ...
                'standinmonth', iris.Configuration.ConversionMonth, @iris.Configuration.validateConversionMonth, true, ...
                }];
            this.nlead = 3;
        end
        
        
        function this = setoptions(this, varargin)
            % Call superclass setoptions to get all options assigned.
            this = setoptions@report.tabularobj(this, varargin{:});
            if isempty(this.options.colstruct) ...
                    && isempty(this.options.range)
                utils.error('report', ...
                    ['In table( ), either ''range'' or ''colstruct'' ', ...
                    'must be specified.']);
            end
            
            % The option `'range'` can include dates with imag parts: `+1i` means a
            % vertical line drawn after the date, `-1i` means a vertical line drawn
            % before the date.
            rng = this.options.range(:).';
            indexOfVLinesBefore = imag(rng) < 0;
            indexOfVLinesAfter = imag(rng) > 0;
            rng = real(rng);
            this.options.vlinebefore = ...
                [this.options.vlinebefore(:).', ...
                rng(indexOfVLinesBefore)];
            this.options.vlineafter = ...
                [this.options.vlineafter(:).', ...
                rng(indexOfVLinesAfter)];
            this.options.range = rng;
            
            isDates = isempty(this.options.colstruct);
            if ~isDates
                nCol = length(this.options.colstruct);
                this.options.range = 1 : nCol;
                for i = 1 : nCol
                    if ischar(this.options.colstruct(i).name)
                        this.options.colstruct(i).name = ...
                            {NaN, ...
                            this.options.colstruct(i).name};
                    end
                end
            end
            
            if isempty(this.options.colstruct)
                tmpRange = this.options.range;
            else
                tmpRange = 1 : numel(this.options.colstruct);
            end
            tmpRange = [tmpRange(1)-1, tmpRange];
            
            % Find positions of vertical lines.
            this.vline = zeros(1, 0);
            for i = reshape(double(this.options.vlineafter), 1, [ ])
                inx = dater.eq(i, tmpRange);
                if any(inx)
                    this.vline(1, end+1) = find(inx) - 1;
                end
            end
            for i = reshape(double(this.options.vlinebefore), 1, [ ])
                inx = dater.eq(i, tmpRange);
                if any(inx)
                    this.vline(1, end+1) = find(inx) - 2;
                end
            end
            
            % Find positions of highlighted columns.
            this.highlight = zeros(1, 0);
            for i = reshape(double(this.options.colhighlight), 1, [ ])
                inx = dater.eq(i, tmpRange);
                if any(inx)
                    this.highlight(1, end+1) = find(inx) - 1;
                end
            end
            if ~isempty(this.highlight)
                this.hInfo.package.colortbl = true;
            end
            
            % Add vertical lines wherever the date frequency changes.
            [~, ~, freq] = dat2ypf(this.options.range);
            this.vline = ...
                unique([this.vline, find([false, diff(freq) ~= 0]) - 1]);
            if ischar(this.options.datejustify)
                this.options.headlinejust = this.options.datejustify;
            end
            this.options.headlinejust = lower(this.options.headlinejust(1));

            % Date format is converted to cellstr, first cell is format for the first
            % dateline or NaN, second cell is format for the second or main dateline.
            if ~iscell(this.options.dateformat)
                this.options.dateformat = {NaN, this.options.dateformat};
            elseif iscell(this.options.dateformat) ...
                    && length(this.options.dateformat) == 1
                this.options.dateformat = [{NaN}, this.options.dateformat];
            end
        end 
        
        
        varargout = headline(varargin)
        
    end

    
    methods (Access=protected, Hidden)
        varargout = speclatexcode(varargin)
    end
    
    
end
