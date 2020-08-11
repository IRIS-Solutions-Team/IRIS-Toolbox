classdef ( ...
    Abstract, CaseInsensitiveProperties=true, ...
    InferiorClasses={?matlab.graphics.axis.Axes, ?DateWrapper} ...
) ...
NumericTimeSubscriptable ...
    < TimeSubscriptable ...
    & shared.GetterSetter ...
    & shared.UserDataContainer

    properties
        % Data  Numeric or logical array of time series data
        Data = double.empty(0, 1) 

        % MissingValue  Representation of missing value
        MissingValue = NaN 
    end


    properties (Dependent)
        % MissingTest  Test for missing values
        MissingTest 
    end


    methods 
        function missingTest = get.MissingTest(this)
            missingValue = this.MissingValue;
            if isequaln(missingValue, NaN)
                missingTest = @isnan;
            elseif isequaln(missingValue, missing)
                missingTest = @ismissing;
            else
                missingTest = @(x) x==missingValue;
            end
        end%
    end


    methods
        varargout = acf(varargin)
        varargout = adiff(varargin)
        varargout = apply(varargin)
        varargout = arf(varargin)
        varargout = apct(varargin)
        varargout = aroc(varargin)
        varargout = bubble(varargin)
        varargout = bwf(varargin)
        varargout = bwf2(varargin)
        varargout = cumsumk(varargin)

        varargout = destdize(varargin)
        function varargout = destdise(varargin)
            [varargout{1:nargout}] = destdize(varargin{:});
        end%

        varargout = diff(varargin)
        varargout = difflog(varargin)
        varargout = ellone(varargin)
        
        function varargout = isfreq(this, freq)
            [varargout{1:nargout}] = this.Frequency==freq;
        end%

        varargout = llf(varargin)
        varargout = llf2(varargin)
        varargout = hpf(varargin)
        varargout = hpf2(varargin)

        varargout = fill(varargin)
        function varargout = replace(varargin)
            [varargout{1:nargout}] = fill(varargin{:});
        end%

        varargout = fillMissing(varargin)
        function varargout = fillmissing(varargin)
            [varargout{1:nargout}] = fillMissing(varargin{:});
        end%

        varargout = filter(varargin)
        varargout = genip(varargin)
        varargout = grow(varargin)
        tabular(varargin)
        varargout = pct(varargin)
        varargout = project(varargin)
        varargout = recognizeShift(varargin)
        varargout = rmse(varargin)
        varargout = roc(varargin)

        function this = round(this, varargin)
            this.Data = round(this.Data, varargin{:});
        end%

        varargout = stdize(varargin)
        function varargout = stdise(varargin)
            [varargout{1:nargout}] = stdize(varargin{:});
        end%

        varargout = table(varargin)
        varargout = vertcat(varargin)
        varargout = yearly(varargin)
    end



    methods (Hidden)
        varargout = checkConsistency(varargin)
    end




    methods (Access=protected, Hidden)
        varargout = binop(varargin)


        function data = createDataFromFunction(this, data, numDates)
            if isequal(data, @ltrend)
                data = transpose(1:numDates);
            else
                data = feval(data, [numDates, 1]);
            end
        end%


        function checkDataClass(this, data)
            if isnumeric(data) || islogical(data) || isstring(data)
                return
            end
            thisError = [ "NumericTimeSubscriptable:InvalidClassOfData"
                          "NumericTimeSubscriptable can only be assigned "
                          "numeric or logical classes of data. "];
            throw(exception.Base(thisError, 'error'));
        end%


        implementDisp(varargin)
        varargout = implementFilter(varargin)
        varargout = unop(varargin)
        varargout = unopinx(varargin)


        function this = resetMissingValue(this, values)
            if isa(values, 'single')
                this.MissingValue = single(NaN);
            elseif islogical(values)
                this.MissingValue = false;
            elseif isinteger(values)
                this.MissingValue = zeros(1, 1, class(values));
            elseif isnumeric(values) && ~isreal(values)
                this.MissingValue = complex(NaN, NaN);
            elseif isstring(values)
                this.MissingValue = string(missing( ));
            else
                this.MissingValue = NaN;
            end
        end%
    end




    methods (Static, Access=protected)
        varargout = plotSwitchboard(varargin)
        varargout = preparePlot(varargin)
    end




    methods (Static)
        varargout = createTable(varargin)
        varargout = getExpSmoothMatrix(varargin)
        varargout = linearTrend(varargin)
    end
    



    methods
        function x = abs(x)
            x.Data = abs(x.Data);
        end%
        function x = acos(x)
            x.Data = acos(x.Data);
            x = trim(x);
        end%
        function x = and(x, y)
            x = binop(@and, x, y);
        end%
        function x = asin(x)
            x.Data = asin(x.Data);
            x = trim(x);
        end%
        function x = atan(x)
            x.Data = atan(x.Data);
            x = trim(x);
        end%
        function x = atan2(x)
            x.Data = atan2(x.Data);
            x = trim(x);
        end%
        function x = ceil(x)
            x.Data = ceil(x.Data);
        end%
        function x = complex(x)
            x.Data = complex(x.Data);
        end%
        function x = cos(x)
            x.Data = cos(x.Data);
            x = trim(x);
        end%
        function x = eq(a, b)
            x = binop(@eq, a, b);
        end%
        function x = exp(x)
            x.Data = exp(x.Data);
            x = trim(x);
        end%
        function x = fix(x)
            x.Data = fix(x.Data);
            x = trim(x);
        end%
        function x = floor(x)
            x.Data = floor(x.Data);
        end%
        function x = ge(a, b)
            x = binop(@ge, a, b);
        end%
        function x = gt(a, b)
            x = binop(@gt, a, b);
        end%
        function x = imag(x)
            x = unop(@imag, x, 0);
            x = trim(x);
        end%
        function x = isinf(x)
            x.Data = isinf(x.Data);
        end%
        function x = isnan(x)
            x.Data = isnan(x.Data);
        end%
        function flag = isreal(x)
            flag = isreal(x.Data);
        end%
        function x = ldivide(a, b)
            x = binop(@ldivide, a, b);
        end%
        function x = le(a, b)
            x = binop(@le, a, b);
        end%
        function x = log(x)
            x.Data = log(x.Data);
            x = trim(x);
        end%
        function x = log10(x)
            x.Data = log10(x.Data);
            x = trim(x);
        end%
        function x = lt(a, b)
            x = binop(@lt, a, b);
        end%
        function x = minus(a, b)
            x = binop(@minus, a, b);
        end%
        function x = mldivide(x, y)
            if (isa(x, 'NumericTimeSubscriptable') && isa(y, 'NumericTimeSubscriptable')) ...
                    || (isnumeric(y) && length(y)==1)
                x = binop(@ldivide, x, y);
            else
                x = binop(@mldivide, x, y);
            end
        end%
        function x = mpower(x, y)
            x = binop(@power, x, y);
        end%
        function x = mrdivide(x, y)
            if (isa(x, 'NumericTimeSubscriptable') && isa(y, 'NumericTimeSubscriptable')) ...
                    || (isnumeric(x) && length(x)==1)
                x = binop(@rdivide, x, y);
            else
                x = binop(@mrdivide, x, y);
            end
        end%
        function x = mtimes(x, y)
            if isa(x, 'NumericTimeSubscriptable') && isa(y, 'NumericTimeSubscriptable')
                x = binop(@times, x, y);
            else
                x = binop(@mtimes, x, y);
            end
        end%
        function x = nanmean(x, dim, varargin)
            if nargin<2
                dim = 1;
            end
            x = unop(@mean, x, dim, dim, 'OmitNaN', varargin{:});
        end%
        function This = nanstd(This, Flag, Dim)
            if nargin<2
                Flag = 0;
            end
            if nargin<3
                Dim = 1;
            end
            % @@@@@ MOSW
            This = unop(@(varargin) tseries.mynanstd(varargin{:}), ...
                This, Dim, Flag, Dim);
        end%
        function This = nansum(This, Dim)
            if nargin<2
                Dim = 1;
            end
            % @@@@@ MOSW
            This = unop(@(varargin) tseries.mynansum(varargin{:}), ...
                This, Dim, Dim);
        end%
        function This = nanvar(This, Flag, Dim)
            if nargin<2
                Flag = 0;
            end
            if nargin<3
                Dim = 1;
            end
            % @@@@@ MOSW
            This = unop(@(varargin) tseries.mynanvar(varargin{:}), ...
                This, Dim, Flag, Dim);
        end%
        function This = ne(This, Y)
            This = binop(@ne, This, Y);
        end%
        function x = norm(x, varargin)
            x = norm(x.Data, varargin{:}) ;
        end%
        function x = not(x)
            x.Data = not(x.Data);
        end%
        function x = or(x, y)
            x = binop(@or, x, y);
        end%
        function x = plus(x, y)
            x = binop(@plus, x, y);
        end%
        function x = power(x, y)
            x = binop(@power, x, y);
        end%
        function x = prod(x, dim)
            if nargin<2
                dim = 1;
            end
            x = unop(@prod, x, dim, dim);
        end%
        function x = rdivide(x, y)
            x = binop(@rdivide, x, y);
        end%
        function x = real(x)
            x.Data = real(x.Data);
            x = trim(x);
        end%
        function x = sin(x)
            x.Data = sin(x.Data);
            x = trim(x);
        end%
        function x = sqrt(x)
            x.Data = sqrt(x.Data);
            x = trim(x);
        end%
        function x = tan(x)
            x.Data = tan(x.Data);
            x = trim(x);
        end%
        function x = times(x, y)
            x = binop(@times, x, y);
        end%
        function x = uminus(x)
            x.Data = -x.Data;
        end%
        function x = uplus(x)
        end%
        
        
        %
        % Distribution functions (Stats Toolbox)
        %
        function x = erf(x, varargin)
            x.Data = erf(x.Data, varargin{:});
            x = trim(x);
        end%
        function x = normcdf(x, varargin)
            x.Data = normcdf(x.Data, varargin{:});
            x = trim(x);
        end%
        function x = normpdf(x, varargin)
            x.Data = normpdf(x.Data, varargin{:});
            x = trim(x);
        end%
        function x = norminv(x, varargin)
            x.Data = norminv(x.Data, varargin{:});
            x = trim(x);
        end%
        function x = logncdf(x, varargin)
            x.Data = logncdf(x.Data, varargin{:});
            x = trim(x);
        end%
        function x = lognpdf(x, varargin)
            x.Data = lognpdf(x.Data, varargin{:});
            x = trim(x);
        end%
        function x = logninv(x, varargin)
            x.Data = logninv(x.Data, varargin{:});
            x = trim(x);
        end%
        function x = gevcdf(x, varargin)
            x.Data = gevcdf(x.Data, varargin{:});
            x = trim(x);
        end%
        function x = gevpdf(x, varargin)
            x.Data = gevpdf(x.Data, varargin{:});
            x = trim(x);
        end%
        function x = gevinv(x, varargin)
            x.Data = gevinv(x.Data, varargin{:});
            x = trim(x);
        end%
        
        
        
        
        %
        % Functions whose behavior differs in different dimensions
        %
        function x = any(x, dim)
            if nargin<2
                dim = 1;
            end
            x = unop(@any, x, dim, dim);
        end%
        function x = all(x, dim)
            if nargin<2
                dim = 1;
            end
            x = unop(@all, x, dim, dim);
        end%
        function x = cumprod(x, dim, varargin)
            if nargin<2
                dim = 1;
            end
            x = unop(@cumprod, x, 0, dim, varargin{:});
        end%
        function x = cumsum(x, dim, varargin)
            if nargin<2
                dim = 1;
            end
            x = unop(@cumsum, x, 0, dim, varargin{:});
        end%
        function a = geomean(x, dim, varargin)
            if nargin<2
                dim = 1;
            end
            a = unop(@geomean, x, dim, dim, varargin{:});
        end%
        function x = mean(x, dim, varargin)
            if nargin <2
                dim = 1;
            end
            x = unop(@mean, x, dim, dim, varargin{:});
        end%


        function x = median(x, dim, varargin)
            if nargin <2
                dim = 1;
            end
            x = unop(@median, x, dim, dim, varargin{:});
        end%


        function x = mode(x, dim, varargin)
            if nargin <2
                dim = 1;
            end
            x = unop(@mode, x, dim, dim, varargin{:});
        end%


        function x = prctile(x, p, dim)
            if nargin<3
                dim = 2;
            end
            x = unop(@numeric.prctile, x, dim, p, dim);
        end%


        function varargout = pctile(varargin)
            [varargout{1:nargout}] = prctile(varargin{:});
        end%


        function x = std(x, flag, dim, varargin)
            if nargin<2
                flag = 0;
            end
            if nargin<3
                dim = 1;
            end
            x = unop(@std, x, dim, flag, dim, varargin{:});
        end%


        function x = sum(x, dim, varargin)
            if nargin<2
                dim = 1;
            end
            x = unop(@sum, x, dim, dim, varargin{:});
        end%


        function x = var(x, flag, dim, varargin)
            if nargin<2
                flag = 0;
            end
            if nargin<3
                dim = 1;
            end
            x = unop(@var, x, dim, flag, dim, varargin{:});
        end%
    end




    methods
        function this = NumericTimeSubscriptable(varargin)
% NumericTimeSubscriptable  Create new numeric time series object
%{
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     X = tseries( )
%     X = tseries(Dates, Values, ~ColumnComments, ~UserData)
%
%
% __Input Arguments__
%
% * `Dates` [ numeric | char ] - Dates for which observations will be
% supplied; `dates` do not need to be sorted in ascending order or create a
% continuous date range. If `dates` is scalar and `values` have multiple
% rows, then the date is interpreted as the start date for the entire time
% series.
%
% * `Values` [ numeric | function_handle ] - Numerical values
% (observations) arranged columnwise, or a function that will be used to
% create an N-by-1 array of values, where N is the number of `dates`.
%
% * `~Comment` [ char | cellstr | string ] - Comment or
% comments attached to each column of observations; if omitted,
% comments will be empty strings.
%
% * `~UserData` [ * ] - Any kind of user data attached to the
% object; if omitted, user data will be empty.
%
%
% __Output Arguments__
%
% * `X` [ tseries ] - New times series.
%
%
% __Description__
%
%
% __Example__
%
%}
            
            % -[IrisToolbox] for Macroeconomic Modeling
            % -Copyright (c) 2007-2020 IRIS Solutions Team
            
            this = this@shared.GetterSetter( );
            this = this@shared.UserDataContainer( );

            % Cast struct as NumericTimeSubscriptable
            if nargin==1 && isstruct(varargin{1}) 
                this = struct2obj(this, varargin{1});
                if ~checkConsistency(this)
                    thisError = [ "NumericTimeSubscriptable:InvalidStructPassedToConstructor"
                                  "The struct passed into the NumericTimeSubscriptable constructor "
                                  "is invalid or its fields are not consistent. " ];
                    throw(exception.Base(thisError, 'error'));
                end
                return
            end

            % Empty call
            if nargin==0
                return
            end
            
            % NumericTimeSubscriptable input
            if nargin==1 && isequal(class(varargin{1}), 'NumericTimeSubscriptable')
                this = varargin{1};
                return
            end

            [dates, values] = varargin{1:2};
            varargin(1:2) = [ ];

            skipInputParserArgument = cell.empty(1, 0);
            if nargin>=3 && (ischar(varargin{end}) || isstring(varargin{end})) ...
                && startsWith(varargin{end}, "--skip", "ignoreCase", true)
                skipInputParserArgument = varargin(end);
                varargin(end) = [ ];
            end
            if ~isempty(varargin)
                comment = varargin{1};
                varargin(1) = [ ];
            else
                comment = [ ];
            end
            if ~isempty(varargin)
                userData = varargin{1};
                varargin(1) = [ ];
            else
                userData = [ ];
            end

            persistent pp
            if isempty(pp)
                pp = extend.InputParser('NumericTimeSubscriptable.NumericTimeSubscriptable');
                pp.KeepDefaultOptions = true;

                addRequired(pp, 'Dates', @DateWrapper.validateDateInput);
                addRequired(pp, 'Values', @(x) isnumeric(x) || islogical(x) || isa(x, 'function_handle') || isstring(x));
                addRequired(pp, 'Comment', @(x) isempty(x) || ischar(x) || iscellstr(x) || isstring(x));
                addRequired(pp, 'UserData');
            end
            skip = maybeSkip(pp, skipInputParserArgument{:});
            if ~skip
                parse(pp, dates, values, comment, userData);
            end

            %
            % Initialize the time series start date and data, trim data
            % array
            %
            this = init(this, dates, values);

            
            %
            % Populate comments for each data column
            %
            if ~skip
                this = resetComment(this);
            end
            if ~isempty(comment)
                this.Comment = comment;
            end


            %
            % Populate user data
            %
            if ~isequal(userData, [ ])
                this = userdata(this, userData);
            end
        end%
    end
end

