classdef Term
    properties
        Position (1, :) double = double.empty(1, 0)
        Shift (1, :) double = 0
        Transform (1, 1) string = "" 

        Expression = [ ]

        Fixed (1, 1) double = NaN
        ContainsLhsName (1, 1) logical = false

        MinShift (1, 1) double = 0
        MaxShift (1, 1) double = 0
    end


    properties (Constant)
        REGISTERED_TRANSFORMS = [ "log", "diff", "difflog" ]
    end


    methods
        function this = Term(varargin)
% Term  Create RHS term for ExplanatoryEquation object
%{
% ## Syntax ##
%
%
%     term = regression.Term(xq, expression)
%     term = regression.Term(xq, position, ...)
%
%
% ## Input Arguments ##
%
%
% __`xq`__ [ ExplanatoryEquation ]
% >
% Parent ExplanatoryEquation object to which the regression.Term will be
% added.
%
%
% __`expression`__ [ string ]
% > 
% Create the regression.Term from a text string describing a possibly
% nonlinear function involving variable names defined in the parent
% ExplanatoryEquation object.
%
%
% __`position`__ [ numeric ]
% >
% Create the regression.Term from a single variable a simple `Transform=`
% function by specifying a pointer to the list of variables names in the
% parent ExplanatoryEquation object.
% 
%
% ## Output Arguments ##
%
% __`term`__ [ regression.Term ]
% >
% New regression.Term object that can be added to its parent
% ExplanatoryEquation object.
%
%
% ## Options ##
%
%
% The following options can be used if the regression.Term is being created
% from a `position`, not from an `expression`.
%
%
% __`Shift=0`__ [ numeric ]
% >
% Time shift (lag or lead) of the explanatory variable.
%
%
% __`Transform=''`__ [ empty | `'diff'` | `'log'` | `'difflog'` ]
% >
% Tranformation of the explanatory variable.
%
%
% __`Fixed=NaN`__ [ `NaN` | numeric ]
% >
% Indicate whether this regression.Term is to be estimated (`Fixed=NaN`) or
% assigned a fixed coefficient (a numeric value).
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 IRIS Solutions Team

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
                %
                % Required arguments
                %
                addRequired(parser, 'xq', @(x) isa(x, 'ExplanatoryEquation'));
                addRequired(parser, 'specification', @(x) (validate.string(x) && isscalar(string(x))) || (validate.numericScalar(x) && isfinite(x) && x==round(x) && x>0));
                %
                % Options
                %
                addParameter(parser, 'Shift', 0, @(x) validate.numericScalar(x) && x==round(x));
                addParameter(parser, 'Transform', [ ], @(x) isempty(x) || validate.anyString(x, regression.Term.REGISTERED_TRANSFORMS)); 
                addParameter(parser, 'Fixed', NaN, @validate.numericScalar);
                addParameter(parser, 'Type', @all, @(x) isequal(x, @all) || isa(x, 'string'));
            end
            parse(parser, varargin{:});
            xq = parser.Results.xq;
            specification = parser.Results.specification;
            opt = parser.Options;

            %
            % Remove a leading plus sign
            %
            if isa(specification, "string") && startsWith(specification, "+")
                specification = replaceBetween(specification, 1, 1, "");
            end

            %
            % Resolve input specification
            %
            resolved = regression.Term.parseInputSpecs(xq, specification, opt.Type);
            needsOptionCheck = false;
            switch resolved.Type
                case {"Name", "Pointer"}
                    this.Position = resolved.Position;
                    this.Shift = opt.Shift;
                    if ~isempty(opt.Transform)
                        this.Transform = opt.Transform;
                    end
                case "Transform"
                    this.Position = resolved.Position;
                    this.Shift = resolved.Shift;
                    this.Transform = resolved.Transform;
                    needsOptionCheck = true;
                case "Expression"
                    this.Expression = resolved.Expression;
                    this.Position = resolved.Positions;
                    this.Shift = resolved.Shifts;
                    this.Transform = "";
                    needsOptionCheck = true;
            end
            if needsOptionCheck && (~isempty(opt.Transform) || opt.Shift~=0)
                hereThrowInvalidTransformOrShift( );
            end
            this.Fixed = opt.Fixed;
            this.MinShift = min([0, this.Shift]);
            this.MaxShift = max([0, this.Shift]);
            if any(this.Transform==["diff", "difflog"])
                this.MinShift = this.MinShift - 1;
            end
            this.ContainsLhsName = containsLhsName(this, xq);

            return




            function hereThrowInvalidTransformOrShift( )
                thisError = [ "ExplanatoryEquation:DefineDependent"
                              "Options Transform= and Shift= can only be specified when the regression.Term is "
                              "entered as a pointer (position) or a plain variable name; otherwise, "
                              "the transform function and the time shift is inferred from the expression string." ];
                throw(exception.Base(thisError, 'error'));
            end%
        end%




        function y = createModelData(this, plainData, t)
            if islogical(t)
                t = find(t);
            end
            numTerms = numel(this);
            numPages = size(plainData, 3);
            numBasePeriods = numel(t);
            y = nan(numTerms, numBasePeriods, numPages);
            for i = 1 : numTerms
                if isa(this(i).Expression, 'function_handle')
                    y__ = this(i).Expression(plainData, t);
                    %
                    % The function may not point to any variables and
                    % produce simply a scalar constant instead; extend the
                    % values throughout the range and pages
                    %
                    if size(y__, 2)==1 && numBasePeriods>1
                        y__ = repmat(y__, 1, numBasePeriods, 1);
                    end
                    if size(y__, 3)==1 && numPages>1
                        y__ = repmat(y__, 1, 1, numPages);
                    end
                    y(i, :, :) = y__;
                    continue
                end
                plainData__ = plainData(this(i).Position, :, :);
                sh = this(i).Shift;
                if isequal(this(i).Transform, "")
                    y(i, :, :) = plainData__(:, t+sh, :);
                    continue
                end
                if isequal(this(i).Transform, "log")
                    y(i, :, :) = log(plainData__(:, t+sh, :));
                    continue
                end
                if isequal(this(i).Transform, "diff")
                    y(i, :, :) = plainData__(:, t+sh, :) - plainData__(:, t+sh-1, :);
                    continue
                end
                if isequal(this(i).Transform, "difflog")
                    y(i, :, :) = log(plainData__(:, t+sh, :)) - log(plainData__(:, t+sh-1, :));
                    continue
                end
            end
        end%




        function plainLhs = updatePlainLhs(this, plainLhs, lhs, t)
            %
            % The input object `this` is always dependent (LHS) terms,
            % and its Position property points to the respective LHS
            % name
            %
            posLhs = this.Position;
            if isequal(this.Transform, "")
                plainLhs(posLhs, t, :) = lhs(:, t, :);
                return
            end
            if isequal(this.Transform, "log")
                plainLhs(posLhs, t, :) = exp(lhs(:, t, :));
                return
            end
            if isequal(this.Transform, "diff")
                plainLhs(posLhs, t, :) = plainLhs(posLhs, t-1, :) + lhs(:, t, :);
                return
            end
            if isequal(this.Transform, "difflog")
                plainLhs(posLhs, t, :) = plainLhs(posLhs, t-1, :) .* exp(lhs(:, t, :));
                return
            end
            thisError = [ "ExplanatoryEquation:InvalidLhsTransformation"
                          "Invalid transformation of the dependent (LHS) term in ExplanatoryEquation." ];
            throw(exception.Base(thisError, 'error'));
        end%




        function rhs = updateOwnExplanatory(this, rhs, plainData, t)
            %
            % The input object `this` is always explanatory (rhs) terms
            %
            for i = find([this.ContainsLhsName])
                rhs(i, t, :) = createModelData(this(i), plainData, t);
            end
        end%




        function dynamic = resolveDynamicOption(this)
            inxOwn = [this.ContainsLhsName];
            if ~any(inxOwn)
                dynamic = false;
                return
            end
            dynamic = any([this(inxOwn).Shift]<0);
        end%




        function flag = isequaln(obj1, obj2)
            if ~isequal(class(obj1), class(obj2))
                flag = false;
                return
            end
            if ~isequal(size(obj1), size(obj2))
                flag = false;
                return
            end
            list = setdiff({metaclass(obj1).PropertyList.Name}, 'Expression');
            for i = 1 : numel(obj1)
                if ~isequal(char(obj1(i).Expression), char(obj2(i).Expression))
                    flag = false;
                    return
                end
                for p = reshape(string(list), 1, [ ])
                    if ~isequaln(obj1(i).(p), obj2(i).(p))
                        flag = false;
                        return
                    end
                end
            end
            flag = true;
        end%
    end




    methods
        function flag = containsLhsName(this, xq)
            flag = any(this.Position==xq.PosOfLhsName);
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




        function this = set.Transform(this, value)
            if isempty(value)
                this.Transform = "";
                return
            end
            this.Transform = value;
        end%
    end




    methods (Static)
        varargout = parseInputSpecs(varargin)
    end
end

