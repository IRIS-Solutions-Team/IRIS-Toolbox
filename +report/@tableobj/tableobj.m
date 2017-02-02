classdef tableobj < report.tabularobj
    
    methods
        
        function This = tableobj(varargin)
            This = This@report.tabularobj(varargin{:});
            This.childof = {'report','align'};
            This.default = [This.default,{ ...
                'colhighlight,highlight',[ ],@isnumeric,true, ...
                'colstruct,columnstruct',struct([ ]), ...
                @(x) isempty(x) || report.genericobj.validatecolstruct(x), ...
                true, ...
                'datejustify',[ ], ...
                @(x) isempty(x) || (ischar(x) && any(strncmpi(x,{'c','l','r'},1))), ...
                true, ...
                'colfootnote',{ },@(x) isempty(x) ...
                || (iscell(x) && all(cellfun(@isnumericscalar,x(1:2:end))) && iscellstr(x(2:2:end))), ...
                true, ...
                'headlinejust','c', ...
                @(x) ischar(x) && any(strncmp(x,{'c','l','r'},1)), ...
                true, ...
                'range',[ ],@isnumeric,true, ...
                'separator','\medskip\par',@ischar,true, ...
                'typeface','',@ischar,false, ...
                'vlineafter,vline',[ ],@isnumeric,true, ...
                'vlinebefore',[ ],@isnumeric,true, ...
                ...
                ... Date format options
                ...---------------------
                'dateformat',@config,@config,true, ...
                'freqletters',@config,@config,true, ...
                'months',@config,@config,true, ...
                'standinmonth',@config,@config,true, ...
                }];
            This.nlead = 3;
        end % table( )
        
        
        function This = setoptions(This,varargin)
            % Call superclass setoptions to get all options assigned.
            This = setoptions@report.tabularobj(This,varargin{:});
            if isempty(This.options.colstruct) ...
                    && isempty(This.options.range)
                utils.error('report', ...
                    ['In table( ), either ''range='' or ''colstruct='' ', ...
                    'must be specified.']);
            end
            
            % The option `'range='` can include dates with imag parts: `+1i` means a
            % vertical line drawn after the date, `-1i` means a vertical line drawn
            % before the date.
            rng = This.options.range(:).';
            inxBefore = imag(rng) < 0;
            inxAfter = imag(rng) > 0;
            rng = real(rng);
            This.options.vlinebefore = ...
                [This.options.vlinebefore(:).', ...
                rng(inxBefore)];
            This.options.vlineafter = ...
                [This.options.vlineafter(:).', ...
                rng(inxAfter)];
            This.options.range = rng;
            
            isDates = isempty(This.options.colstruct);
            if ~isDates
                nCol = length(This.options.colstruct);
                This.options.range = 1 : nCol;
                for i = 1 : nCol
                    if ischar(This.options.colstruct(i).name)
                        This.options.colstruct(i).name = ...
                            {NaN, ...
                            This.options.colstruct(i).name};
                    end
                end
            end
            
            if isempty(This.options.colstruct)
                tmpRange = This.options.range;
            else
                tmpRange = 1 : length(This.options.colstruct);
            end
            tmpRange = [tmpRange(1)-1,tmpRange];
            
            % Find positions of vertical lines.
            This.vline = zeros(1,0);
            for i = This.options.vlineafter(:).'
                inx = datcmp(i,tmpRange);
                if any(inx)
                    This.vline(1,end+1) = find(inx) - 1;
                end
            end
            for i = This.options.vlinebefore(:).'
                inx = datcmp(i,tmpRange);
                if any(inx)
                    This.vline(1,end+1) = find(inx) - 2;
                end
            end
            
            % Find positions of highlighted columns.
            This.highlight = zeros(1,0);
            for i = This.options.colhighlight(:).'
                inx = datcmp(i,tmpRange);
                if any(inx)
                    This.highlight(1,end+1) = find(inx) - 1;
                end
            end
            if ~isempty(This.highlight)
                This.hInfo.package.colortbl = true;
            end
            
            % Add vertical lines wherever the date frequency changes.
            [~,~,freq] = dat2ypf(This.options.range);
            This.vline = ...
                unique([This.vline,find([false,diff(freq) ~= 0]) - 1]);
            if ischar(This.options.datejustify)
                utils.warning('report', ...
                    ['The option ''datejustify'' in report/band is obsolete ', ...
                    'and will be removed from future IRIS versions. ', ...
                    'Use ''headlinejust'' instead.']);
                This.options.headlinejust = This.options.datejustify;
            end
            This.options.headlinejust = lower(This.options.headlinejust(1));

            % Date format is converted to cellstr, first cell is format for the first
            % dateline or NaN, second cell is format for the second or main dateline.
            if ~iscell(This.options.dateformat)
                This.options.dateformat = {NaN,This.options.dateformat};
            elseif iscell(This.options.dateformat) ...
                    && length(This.options.dateformat) == 1
                This.options.dateformat = [{NaN},This.options.dateformat];
            end
        end % setoptions( )
        
        
        varargout = headline(varargin)
        
    end

    
    methods (Access=protected,Hidden)
        varargout = speclatexcode(varargin)
    end
    
    
end
