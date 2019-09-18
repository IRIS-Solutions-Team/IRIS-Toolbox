classdef Term
    properties
        Position (1, :) double = 1
        Shift (1, 1) double = 0
        Transform (1, 1) string = "" 

        Expression = [ ]

        Fixed (1, 1) double = NaN
        ContainsLhsNames (1, 1) logical = false

        MinShift (1, 1) double = 0
        MaxShift (1, 1) double = 0
    end


    methods
        function this = Term(varargin)
            if nargin==0
                return
            end
            if nargin==1 && isa(varargin{1}, 'regression.Term')
                this = varargin{1};
                return
            end

            persistent parser
            if isempty(parser)
                parser = extend.InputParser('regression.Term');
                % Required arguments
                addRequired(parser, 'regression', @(x) isa(x, 'LinearRegression'));
                addRequired(parser, 'expression', @(x) validate.string(x) && isscalar(string(x)));
                % Options
                addParameter(parser, 'Shift', 0, @(x) validate.numericScalar(x) && x==round(x));
                addParameter(parser, 'Transform', "", @(x) validate.anyString(x, 'diff', 'difflog', 'log')); 
                addParameter(parser, 'Fixed', NaN, @validate.numericScalar);
            end
            parse(parser, varargin{:});
            regression = parser.Results.regression;
            expression = parser.Results.expression;
            opt = parser.Options;

            % Resolve expression
            expression = strtrim(expression);
            this.Position = getPositionOfName(regression, expression);
            if ~isnan(this.Position)
                this.Shift = opt.Shift;
                this.Transform = string(opt.Transform);
                this.MinShift = this.Shift;
                if isequal(this.Transform, "diff") || isequal(this.Transform, "difflog")
                    this.MinShift = this.MinShift - 1;
                end
                this.MaxShift = this.Shift;
            else
                this = parseExpression(this, regression, expression);
            end
            this.Fixed = opt.Fixed;
            this.ContainsLhsNames = containsLhsNames(this, regression);
        end%




        function y = createModelData(this, plainData, t)
            if islogical(t)
                t = find(t);
            end
            if isa(this.Expression, 'function_handle')
                y = this.Expression(plainData, t);
                return
            end
            x = plainData(this.Position, :, :);
            sh = this.Shift;
            if isequal(this.Transform, "")
                y = x(:, t+sh, :);
                return
            end
            if isequal(this.Transform, "log")
                y = log(x(:, t+sh, :));
                return
            end
            if isequal(this.Transform, "diff")
                y = x(:, t+sh, :) - x(:, t+sh-1, :);
                return
            end
            if isequal(this.Transform, "difflog")
                y = log(x(:, t+sh, :)) - log(x(:, t+sh-1, :));
                return
            end
        end%




        function plainLhs = updatePlainLhs(this, plainLhs, y, t)
            if isequal(this.Transform, "")
                plainLhs(:, t) = y(:, t);
                return
            end
            if isequal(this.Transform, "log")
                plainLhs(:, t) = exp(y(:, t));
                return
            end
            if isequal(this.Transform, "diff")
                plainLhs(:, t) = plainLhs(:, t-1) + y(:, t);
                return
            end
            if isequal(this.Transform, "difflog")
                plainLhs(:, t) = plainLhs(:, t-1) .* exp(y(:, t));
                return
            end
            thisError = { 'Regression:Term:CannotUpdateLhsVariable'
                          'Cannot update LHS variable in LinearRegression simulation' };
            throw( exception.Base(thisError, 'error') );
        end%




        function X = updateOwnExplanatory(this, X, plainLhs, t)
            for i = find([this.ContainsLhsNames])
                X(i, t, :) = createModelData(this(i), plainLhs, t);
            end
        end%
    end




    methods
        function flag = containsLhsNames(this, regression)
            flag = any(ismember(this.Position, regression.PosOfLhsNames));
        end%




        function output = eq(this, that)
            numThis = numel(this);
            numThat = numel(that);
            if numThis==1 && numThat>1
                this = repmat(this, size(that));
            elseif numThis>1 && numThat==1
                that = repmat(that, size(this));
            end
            output = arrayfun(@isequal, this, that);
        end%
    end




    methods (Access=protected)
        varargout = parseExpression(varargin)
    end
end

