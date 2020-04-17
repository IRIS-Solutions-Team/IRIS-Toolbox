classdef Term
    properties
        Incidence (1, :) double = double.empty(1, 0)
        Position (1, 1) double = NaN
        Shift (1, 1) double = 0
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


    methods % Constructor
        function this = Term(varargin)
% Term  Create RHS term for Explanatory object
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
% __`xq`__ [ Explanatory ]
% >
% Parent Explanatory object to which the regression.Term will be
% added.
%
%
% __`expression`__ [ string ]
% > 
% Create the regression.Term from a text string describing a possibly
% nonlinear function involving variable names defined in the parent
% Explanatory object.
%
%
% __`position`__ [ numeric ]
% >
% Create the regression.Term from a single variable a simple `Transform=`
% function by specifying a pointer to the list of variables names in the
% parent Explanatory object.
% 
%
% ## Output Arguments ##
%
% __`term`__ [ regression.Term ]
% >
% New regression.Term object that can be added to its parent
% Explanatory object.
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
% -Copyright (c) 2007-2020 IRIS Solutions Team

            if nargin==0
                return
            end
            if nargin==1 && isa(varargin{1}, 'regression.Term')
                this = varargin{1};
                return
            end

            persistent pp
            if isempty(pp)
                pp = extend.InputParser('regression.Term');

                addRequired(pp, 'xq', @(x) isa(x, 'Explanatory'));
                addRequired(pp, 'specification', @(x) validate.stringScalar(x) || validate.roundScalar(x, [1, intmax]));

                addParameter(pp, 'Shift', @auto, @(x) isequal(x, @auto) || validate.roundScalar(x));
                addParameter(pp, 'Transform', @auto, @(x) isequal(x, @auto) || validate.anyString(x, regression.Term.REGISTERED_TRANSFORMS)); 
                addParameter(pp, 'Fixed', NaN, @validate.numericScalar);
                addParameter(pp, 'Type', @all, @(x) isequal(x, @all) || isa(x, 'string'));
            end
            parse(pp, varargin{:});
            xq = pp.Results.xq;
            specification = pp.Results.specification;
            opt = pp.Options;

            %
            % Remove a leading plus sign
            %
            if isa(specification, "string") && startsWith(specification, "+")
                specification = replaceBetween(specification, 1, 1, "");
            end

            %
            % Resolve input specification
            %
            resolved = regression.Term.parseInputSpecs(xq, specification, opt.Transform, opt.Shift, opt.Type);

            this.Incidence = resolved.Incidence;
            this.Transform = resolved.Transform;
            this.Position = resolved.Position;
            this.Shift = resolved.Shift;
            this.Expression = resolved.Expression;

            needsCheckOptions = resolved.Type=="Transform" || resolved.Type=="Expression";
            if needsCheckOptions && (~isequal(opt.Transform, @auto) || ~isequal(opt.Shift, @auto))
                hereThrowInvalidTransformOrShift( );
            end

            this.Fixed = opt.Fixed;
            imagIncidence0 = [imag(this.Incidence), 0];
            this.MinShift = min(imagIncidence0);
            this.MaxShift = max(imagIncidence0);

            return

                function hereThrowInvalidTransformOrShift( )
                    thisError = [ "Explanatory:DefineDependent"
                                  "Options Transform= and Shift= can only be specified when the regression.Term is "
                                  "entered as a pointer (position) or a plain variable name; otherwise, "
                                  "the transform function and the time shift is inferred from the expression string." ];
                    throw(exception.Base(thisError, 'error'));
                end%
        end%
    end




    methods
        function y = createModelData(this, plainData, t, date, controls)
            if islogical(t)
                t = find(t);
            end
            numTerms = numel(this);
            numPages = size(plainData, 3);
            numBasePeriods = numel(t);
            y = nan(numTerms, numBasePeriods, numPages);
            for i = 1 : numTerms
                this__ = this(i);
                if isa(this__.Expression, 'function_handle')
                    y__ = this__.Expression(plainData, t, date, controls);
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
                %
                % If `Expression` is empty, then `Position` and `Shift` are
                % both scalars
                %
                plainData__ = plainData(this__.Position, :, :);
                sh = this__.Shift;
                if this__.Transform==""
                    y(i, :, :) = plainData__(:, t+sh, :);
                    continue
                end
                if this__.Transform=="log"
                    y(i, :, :) = log(plainData__(:, t+sh, :));
                    continue
                end
                if this__.Transform=="diff"
                    y(i, :, :) = plainData__(:, t+sh, :) - plainData__(:, t+sh-1, :);
                    continue
                end
                if this__.Transform=="difflog"
                    y(i, :, :) = log(plainData__(:, t+sh, :)) - log(plainData__(:, t+sh-1, :));
                    continue
                end
            end
        end%




        function plainData = updatePlainData(this, plainData, lhs, res, t)
            %
            % Update residuals first; residuals are ordered last in the
            % plainData array
            %
            if ~isempty(res)
                posResiduals = size(plainData, 1);
                plainData(posResiduals, t, :) = res(1, t, :);
            end
            %
            % The input object `this` is always a dependent (LHS) terms,
            % and its Position property points to the respective LHS
            % name
            %
            posLhs = this.Position;
            if isequal(this.Transform, "")
                plainData(posLhs, t, :) = lhs(:, t, :);
                return
            end
            if isequal(this.Transform, "log")
                plainData(posLhs, t, :) = exp(lhs(:, t, :));
                return
            end
            if isequal(this.Transform, "diff")
                plainData(posLhs, t, :) = plainData(posLhs, t-1, :) + lhs(:, t, :);
                return
            end
            if isequal(this.Transform, "difflog")
                plainData(posLhs, t, :) = plainData(posLhs, t-1, :) .* exp(lhs(:, t, :));
                return
            end
            thisError = [ "Explanatory:InvalidLhsTransformation"
                          "Invalid transformation of the dependent (LHS) term in Explanatory." ];
            throw(exception.Base(thisError, 'error'));
        end%




        function rhs = updateOwnExplanatory(this, rhs, plainData, t, date, controls)
            %
            % The input object `this` is always explanatory (rhs) terms
            %
            for i = find([this.ContainsLhsName])
                rhs(i, t, :) = createModelData(this(i), plainData, t, date, controls);
            end
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
            if isempty(obj1) && isempty(obj2)
                flag = true;
                return
            end
            meta = ?regression.Term;
            list = setdiff({meta.PropertyList.Name}, 'Expression');
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
            flag = any(real(this.Incidence)==xq.PosOfLhsName);
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

