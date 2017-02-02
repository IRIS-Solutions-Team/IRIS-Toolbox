% trec  Time-Recursive Expressions (trec Objects).
%
% Time-recursive subscript objects (trec objects) allow creating and
% evaluating time-recursive expressions based on
% [tseries](tseries/Contents) objects. Read below carefully when IRIS fails
% to evaluate time-recursive expessions correctly.
%
% Trec methods:
%
%
% Constructor
% ============
%
% * [`trec`](trec/trec) - Create new recursive time subscript object.
%
%
% Creating lags and leads
% ========================
%
% * [`plus`](trec/plus) - Create time-recursive lead of tseries object.
% * [`minus`](trec/minus) - Create time-recursive lag of tseries object.
%
%
% Using Time-Recursive Subscripts
% ================================
%
% Time-recursive expressions are expressions that are evaluated period by
% period, with each result assigned immediately to the left-hand side
% tseries variable, and used in subsequent periods evaluated afterwards.
%
% To construct and evaluate time-recursive expressions, use tseries
% referenced by a trec object, or a lag or lead created from a trec object.
% Every tseries object on both the left-hand side (i.e. the variable under
% construction) and the right-hand side (i.e. the variables in the
% expression that is being evaluated) must be referenced by a trec object
% (or possibly a lag or lead). When referencing a tseries object by a trec,
% you can use either curly braces, `{...}`, or round brackets, `(...)`;
% there is no difference between them in time-recursive expressions.
%
% $\attention$ See the description below of situations when IRIS fails to
% evaluate time-recursive expressions correctly, and how to avoid/fix such
% situations.
%
%
% Example
% ========
%
% Construct an autoregressive sequence starting from an initial value of 10
% with a autoregressive coefficient 0.8 between periods 2010Q1 and 2020Q4:
%
%     T = trec(qq(2010,1):qq(2020,4));
%     x = Series(qq(2009,4),10);
%     x{T} = 0.8*x{T-1};
%
%
% Example
% ========
%
% Construct a first-order autoregressive process, `x`, with normally
% distributed innovations, `e`:
%
%     T = trec(qq(2010,1):qq(2020,4));
%     x = Series(qq(2009,4),10);
%     e = Series(qq(2010,1):qq(2020,4),@randn);
%     x{T} = (1-0.8)*10 + 0.8*x{T-1} + e{T};
%
%
% Example
% ========
%
% Construct a second-order log-autoregressive process going backward from
% year 2020 to year 2000.
%
%     T = trec(yy(2020):-1:yy(2000));
%     b = Series( );
%     b(yy(2022)) = 1.56;
%     b(yy(2021)) = 1.32;
%     b{T} = b{T+1}^1.2 / b{T+2}^0.6;
%
%
% Example
% ========
%
% Construct the first 20 numbers of the Fibonacci sequence:
%
%      T = trec(3:20);
%      f = Series(1:2,1);
%      f{T} = f{T-1} + f{T-2};
%
%
% When IRIS Fails to Evaluate Time-Recursive Expressions Correctly
% =================================================================
%
% $\attention$ IRIS fails to evaluate time-recursive expressions correctly
% (without any indication of an error) when the following two circumstances
% occur _at the same time_:
%
% * At least one tseries object on the right-hand side has been created by
% copying the left-hand side tseries object with no further manipulation.
%
% * The time series used in the expression are within a database (struct),
% or a cell array;
%
% Under these circumstances, the right-hand side tseries variable will be assigned
% (updated with) the results calculated in iteration as if it were the
% tseries variable on the left-hand side.
%
%
% Example
% ========
%
% Create a database with two tseries. Create one of the tseries by simply
% copying the other (i.e. plain assignment with no further manipulation).
%
%     d = struct( );
%     d.x = Series(1:10,1);
%     d.y = d.x;
%
%     T = trec(2:10);
%     d.x{T} = 0.8*d.y{T-1}; % Fails to evaluate correctly.
%
% The above time-recursive expression will be incorrectly evaluated as if
% it were `d.x{T} = 0.8*d.x{T-1}`. However, when the tseries objects are
% not stored within a database (struct) but exist as stand-alone variables,
% the expression will evaluate correctly:
%
%     x = Series(1:10,1);
%     y = x;
%
%     T = trec(2:10);
%     x{T} = 0.8*y{T-1}; % Evaluates correctly.
%
%
% Workaround when Time-Recursive Expressions Fail
% ================================================
%
% $\attention$ To evaluate the expression correctly, simply apply any kind
% of operator or function to the tseries `d.y` before it enters the
% time-recursive expression. Below are examples of some simple
% manipulations that do the job without changing the tseries `d.y`:
%
%     d = struct( );
%     d.x = Series(1:10,1);
%     d.y = 1*d.x;
%
% or
%
%     d = struct( );
%     d.x = Series(1:10,1);
%     d.y = d.x{:};
%
% or
%
%     d = struct( );
%     d.x = Series(1:10,1);
%     d.y = d.x;
%     d.y = d.y + 0;
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

classdef trec < shared.GetterSetter
    properties
        Dates = [ ];
        Shift = 0;
    end
    
    
    methods
        function This = trec(varargin)
            % trec  Create new recursive time subscript object.
            %
            % Syntax
            % =======
            %
            %     T = trec(Dates)
            %
            % Input arguments
            % ================
            %
            % * `Dates` [ numeric ] - Vector of dates or date range on which the final
            % time-recursive expression will be evaluated.
            %
            % Output arguments
            % =================
            %
            % * `T` [ trec ] - New time-recursive subscript object.
            %
            % Description
            % ============
            %
            % Time-recursive subscript objects are used to reference tseries objects on
            % both the left-hand side and the right-hand side of a time-recursive
            % assignment. The assignment is then evaluated for each date in `Dates`,
            % from the first to the last.
            %
            % See more on time-recursive expressions in [Contents](trec/Contents),
            % including the description of instances in which IRIS fails to evaluate
            % the time-recursive expressions correctly.
            %
            % Example
            % ========
            %
            % Construct a first-order autoregressive process with normally distributed
            % residuals:
            %
            %     T = trec(qq(2010,1):qq(2020,4));
            %     x = Series(qq(2009,4),10);
            %     e = Series(qq(2010,1):qq(2020,4),@randn);
            %     x(T) = 10 + 0.8*x(T-1) + e(T);
            %
            %
            
            % -IRIS Macroeconomic Modeling Toolbox.
            % -Copyright (c) 2007-2017 IRIS Solutions Team.
            
            %--------------------------------------------------------------
            
            if isempty(varargin)
                return
            end
            if length(varargin) == 1 && isa(varargin{1},'trec')
                This = varargin{1};
                return
            end
            if length(varargin) == 1 && isnumeric(varargin{1})
                This.Dates = varargin{1};
                return
            end
        end
    end
    
    
    methods
        varargout = plus(varargin)
        varargout = minus(varargin)
        
        
        function This = set.Dates(This,X)
            if any(~freqcmp(X))
                utils.error('trec:Range', ...
                    ['Multiple frequencies not allowed in date vectors ', ...
                    'in time-recursive expressions.']);
            end
            This.Dates = X;
        end
        
        
        function This = set.Shift(This,X)
            if ~isintscalar(X)
                utils.error('trec:Shift', ...
                    ['Lags and leads must be integer scalars ', ...
                    'in time-recursive expressions.']);
            end
            This.Shift = X;
        end
    end
    
end
