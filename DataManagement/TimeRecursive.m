% # TimeRecursive Objects #
%
% TimeRerusive objects are used to evaluate time series assignments period
% by period over a certain time horizon. If the RHS of the expression
% includes lags of the time series on the LHS, these lagged values are
% evaluated recursively.
%

classdef TimeRecursive
    properties
        Dates = @empty
    end


    properties (Constant, Hidden);
        DEFAULT_NAME_OF_TIME_INDEX = 'T';
        TIME_SERIES_VALUE_REFERENCE = '(%s)';
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
        end%


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
                error( 'TimeRecursive:colon', ...
                       'TimeRecursive expressions must be a string, char or cellstr' );
            end
            expressionsToEval = strtrim(expressionsToEval);
            numOfExpressions = numel(expressionsToEval);
            numOfDates = numel(this.Dates);

            nameOfTimeIndex = this.DEFAULT_NAME_OF_TIME_INDEX;
            while evalin('caller', sprintf('exist(''%s'')', nameOfTimeIndex))>0
                nameOfTimeIndex = [nameOfTimeIndex, '_'];
            end

            for i = 1 : numOfExpressions
                ithExpression = expressionsToEval{i};
                while true
                    [tkn, from, to] = regexp( ithExpression, ...
                                              '(\<[a-zA-Z][\w\.]*\>)(\{[^\}]*\})?(?![\$\(\{])', ...
                                              'tokens', 'start', 'end', 'once' );
                    if isempty(tkn)
                        break
                    end
                    try
                        flag = evalin('caller', sprintf('isa(%s, ''Series'')', tkn{1}));
                    catch
                        flag = false;
                    end
                    if ~isequal(flag, true)
                        error( 'TimeRecursive:colon', ...
                               'TimeRecursive expression must have a tseries or Series object on the LHS' );
                    end
                    if isequal(flag, true)
                        ithExpression = [ithExpression(1:to), '$', ithExpression(to+1:end)];
                    end
                end
                ithExpression = strrep( ithExpression, ...
                                        '$', ...
                                        sprintf(this.TIME_SERIES_VALUE_REFERENCE, nameOfTimeIndex) );
                if ithExpression(end)~=';'
                    ithExpression = [ithExpression, ';'];
                end
                expressionsToEval{i} = ithExpression;
            end

            dates = double(this.Dates);
            for t = 1 : numOfDates
                jthDate = dates(t);
                for i = 1 : numOfExpressions
                    assignin('caller', nameOfTimeIndex, jthDate);
                    evalin('caller', expressionsToEval{i});
                end
            end

            evalin('caller', sprintf('clear %s', nameOfTimeIndex));
        end%
    end
end
