classdef TimeRecursive
    properties
        Dates = @empty
    end


    properties (Dependent)
        TimeSeriesClass 
    end


    properties (Constant)
        DEFAULT_NAME_OF_TIME_INDEX = 'T';
        TIME_SERIES_VALUE_REFERENCE = '{%s}';
    end


    methods
        function this = TimeRecursive(varargin)
            if nargin==0
                return
            end
            if nargin==1 && isa(varargin{1}, 'TimeRecursive')
                this = varargin{1};
            end
            this.Dates = varargin{1};
        end


        function colon(this, varargin)
            if iscellstr(varargin{1})
                % TimeRecursive : {'x=...', 'y=...'}
                expressionsToEval = varargin{1};
            elseif ischar(varargin{1})
                % TimeRecursive : 'x=...'
                expressionsToEval = varargin(1);
            elseif isa(varargin{1}, 'string')
                % TimeRecursive : "x=..."
                % TimeRecursive : ["x=...", "y=..."]
                expressionsToEval = cellstr(varargin{1});
            else
                error( ...
                    'TimeRecursive:colon', ...
                    'TimeRecursive expressions must be a string, char or cellstr.' ...
                );
            end
            expressionsToEval = strtrim(expressionsToEval);
            numExpressions = numel(expressionsToEval);
            numDates = numel(this.Dates);

            nameOfTimeIndex = this.DEFAULT_NAME_OF_TIME_INDEX;
            while evalin('caller', sprintf('exist(''%s'')', nameOfTimeIndex))>0
                nameOfTimeIndex = [nameOfTimeIndex, '_'];
            end

            addSemicolon = repmat({''}, size(expressionsToEval));
            for i = 1 : numExpressions
                ithExpression = expressionsToEval{i};
                while true
                    [tkn, from, to] = regexp( ...
                        ithExpression, ...
                        '(\<[a-zA-Z][\w\.]*\>)(\{[^\}]*\})?(?![\$\(\{])', ...
                        'tokens', 'start', 'end', 'once' ...
                    );
                    if isempty(tkn)
                        break
                    end
                    try
                        flag = evalin('caller', sprintf('isa(%s, ''%s'')', tkn{1}, this.TimeSeriesClass));
                    catch
                        flag = false;
                    end
                    assert( ...
                        isequal(flag, true), ...
                        'TimeRecursive:colon', ...
                        'TimeRecursive expression must have a %s on its LHS.', ...
                        this.TimeSeriesClass ...
                    );
                    if isequal(flag, true)
                        ithExpression = [ithExpression(1:to), '$', ithExpression(to+1:end)];
                    end
                end
                ithExpression = strrep( ...
                    ithExpression, ...
                    '$', ...
                    sprintf(this.TIME_SERIES_VALUE_REFERENCE, nameOfTimeIndex) ...
                );
                if ithExpression(end)~=';'
                    addSemicolon{i} = ';';
                end
                expressionsToEval{i} = ithExpression;
            end

            for i = 1 : numExpressions
                ithExpression = expressionsToEval{i};
                ithAddSemicolon = addSemicolon{i};
                for i = 1 : numDates
                    ithDate = this.Dates(i);
                    assignin('caller', nameOfTimeIndex, ithDate);
                    if i<numDates
                        evalin('caller', [ithExpression, ithAddSemicolon]);
                    else
                        evalin('caller', ithExpression);
                    end
                end
            end

            evalin('caller', sprintf('clear %s', nameOfTimeIndex));
        end


        function timeSeriesClass = get.TimeSeriesClass(this)
            if isa(this.Dates, 'Date')
                timeSeriesClass = 'TimeSeries';
            elseif isa(this.Dates, 'DateWrapper') || isnumeric(this.Dates)
                timeSeriesClass = 'tseries';
            else
                timeSeriesClass = '?';
            end
        end
    end
end
