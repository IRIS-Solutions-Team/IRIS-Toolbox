classdef Term
    properties
        Incidence (1, :) double = double.empty(1, 0)
        Position (1, 1) double = NaN
        Shift (1, 1) double = 0
        Transform (1, 1) string = "" 

        Expression = [ ]

        ContainsLhsName (1, 1) logical = false

        MinShift (1, 1) double = 0
        MaxShift (1, 1) double = 0
    end


    properties (Constant)
        %(
        TRANSFORMS = struct( ...
            "log", @(plainData, row, t, sh) log(plainData(row, t+sh, :)) ... 
            , "exp", @(plainData, row, t, sh) exp(plainData(row, t+sh, :)) ... 
            , "diff", @(plainData, row, t, sh) plainData(row, t+sh, :) - plainData(row, t+sh-1, :) ...
            , "difflog", @(plainData, row, t, sh) log(plainData(row, t+sh, :)) - log(plainData(row, t+sh-1, :)) ...
            , "roc", @(plainData, row, t, sh) plainData(row, t+sh, :) ./ plainData(row, t+sh-1, :) ...
            , "pct", @(plainData, row, t, sh) 100*(plainData(row, t+sh, :) ./ plainData(row, t+sh-1, :) - 1) ...
        )

        INV_TRANSFORMS = struct( ...
            "log", @(lhs, plainData, row, t) exp(plainData(row, t+sh, :)) ... 
            , "exp", @(lhs, plainData, row, t) log(lhs, plainData(row, t+sh, :)) ... 
            , "diff", @(lhs, plainData, row, t) plainData(row, t-1, :) + lhs(:, t, :) ...
            , "difflog", @(lhs, plainData, row, t) plainData(row, t-1, :) .* exp(lhs(:, t, :)) ...
            , "roc", @(lhs, plainData, row, t) plainData(row, t-1, :) .* lhs(:, t, :) ...
            , "pct", @(lhs, plainData, row, t) plainData(row, t-1, :) .* (1 + lhs(:, t, :)/100) ...
        )

        TRANSFORMS_SHIFTS = struct( ...
            "log", double.empty(1, 0) ...
            , "exp", double.empty(1, 0) ... 
            , "diff", -1 ...
            , "difflog", -1 ...
            , "roc", -1 ...
            , "pct", -1 ...
        )
        %)
    end


    methods % Constructor
        function this = Term(varargin)
% Term  Create RHS term for Explanatory object
%{
% ## Syntax ##
%
%
%     term = regression.Term(expy, expression)
%     term = regression.Term(expy, position, ...)
%
%
% ## Input Arguments ##
%
%
% __`expy`__ [ Explanatory ]
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

            %( Input parser
            persistent pp
            if isempty(pp)
                pp = extend.InputParser('regression.Term');

                addRequired(pp, 'expy', @(x) isa(x, 'Explanatory'));
                addRequired(pp, 'specification', @(x) validate.stringScalar(x) || validate.roundScalar(x, [1, intmax]));

                addParameter(pp, 'Shift', @auto, @(x) isequal(x, @auto) || validate.roundScalar(x));
                addParameter(pp, 'Transform', @auto, @(x) isequal(x, @auto) || validate.anyString(x, keys(regression.Term.TRANSFORMS))); 
                addParameter(pp, 'Type', @all, @(x) isequal(x, @all) || isa(x, 'string'));
            end
            %)
            opt = parse(pp, varargin{:});
            expy = pp.Results.expy;
            specification = pp.Results.specification;

            %
            % Remove a leading plus sign
            %
            if isa(specification, "string") && startsWith(specification, "+")
                specification = replaceBetween(specification, 1, 1, "");
            end

            %
            % Resolve input specification
            %
            resolved = regression.Term.parseInputSpecs(expy, specification, opt.Transform, opt.Shift, opt.Type);

            this.Incidence = resolved.Incidence;
            this.Transform = resolved.Transform;
            this.Position = resolved.Position;
            this.Shift = resolved.Shift;
            this.Expression = resolved.Expression;

            needsCheckOptions = resolved.Type=="Transform" || resolved.Type=="Expression";
            if needsCheckOptions && (~isequal(opt.Transform, @auto) || ~isequal(opt.Shift, @auto))
                hereThrowInvalidTransformOrShift( );
            end

            imagIncidence0 = [imag(this.Incidence), 0];
            this.MinShift = min(imagIncidence0);
            this.MaxShift = max(imagIncidence0);

            return

                function hereThrowInvalidTransformOrShift( )
                    %(
                    thisError = [ 
                        "Explanatory:DefineDependentTerm"
                        "Options Transform= and Shift= can only be specified when the regression.Term is "
                        "entered as a pointer (position) or a plain variable name; otherwise, "
                        "the transform function and the time shift is inferred from the expression string." 
                    ];
                    throw(exception.Base(thisError, 'error'));
                    %)
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
                pos = this__.Position;
                sh = this__.Shift;
                if this__.Transform==""
                    y(i, :, :) = plainData(pos, t+sh, :);
                else
                    y(i, :, :) = regression.Term.TRANSFORMS.(this__.Transform)(plainData, pos, t, sh);
                end
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
        function flag = containsLhsName(this, expy)
            flag = any(real(this.Incidence)==expy.PosLhsName);
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




%
% Unit Tests 
%{
##### SOURCE BEGIN #####
% saveAs=Explanatory/regressionTermUnitTest.m

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);

% Set up once
    expy = Explanatory( );
    expy = setp(expy, 'VariableNames', ["x", "y", "z"]);
    output = struct( );
    output.Type = "";
    output.Transform = "";
    output.Incidence = double.empty(1, 0);
    output.Position = NaN;
    output.Shift = 0;
    output.Expression = [ ];
    testCase.TestData.Model = expy;
    testCase.TestData.Output = output;


%% Test Pointer
    expy = testCase.TestData.Model;
    for ptr = 1 : numel(expy.VariableNames)
        act = regression.Term.parseInputSpecs(expy, ptr, @auto, @auto, @all);
        exd = testCase.TestData.Output;
        exd.Type = "Pointer";
        exd.Incidence = complex(ptr, 0);
        exd.Position = ptr;
        assertEqual(testCase, act, exd);
    end


%% Test Name
    expy = testCase.TestData.Model;
    for name = expy.VariableNames
        act = regression.Term.parseInputSpecs(expy, name, @auto, @auto, @all);
        exd = testCase.TestData.Output;
        exd.Type = "Name";
        ptr = find(name==expy.VariableNames);
        exd.Incidence = complex(ptr, 0);
        exd.Position = ptr;
        assertEqual(testCase, act, exd);
    end


%% Test Name Shift
    expy = testCase.TestData.Model;
    for name = expy.VariableNames
        act = regression.Term.parseInputSpecs(expy, name + "{-1}", @auto, @auto, @all);
        exd = testCase.TestData.Output;
        exd.Type = "Name";
        ptr = find(name==expy.VariableNames);
        exd.Incidence = complex(ptr, -1);
        exd.Position = ptr;
        exd.Shift = -1;
        assertEqual(testCase, act, exd);
    end


%% Test Name Difflog
    expy = testCase.TestData.Model;
    for name = expy.VariableNames
        act = regression.Term.parseInputSpecs(expy, "difflog(" + name + ")", @auto, @auto, @all);
        exd = testCase.TestData.Output;
        exd.Type = "Transform";
        ptr = find(name==expy.VariableNames);
        exd.Transform = "difflog";
        exd.Incidence = [complex(ptr, 0), complex(ptr, -1)];
        exd.Position = ptr;
        exd.Shift = 0;
        assertEqual(testCase, act, exd);
    end


%% Test Transform
    expy = testCase.TestData.Model;
    for name = expy.VariableNames
        for transform = keys(regression.Term.TRANSFORMS)
            act = regression.Term.parseInputSpecs(expy, transform + "(" + name + ")", @auto, @auto, @all);
            ptr = find(name==expy.VariableNames);
            exd = testCase.TestData.Output;
            exd.Type = "Transform";
            exd.Transform = transform;
            exd.Incidence = complex(ptr, 0);
            shift = regression.Term.TRANSFORMS_SHIFTS.(transform);
            if ~isempty(shift)
                exd.Incidence = [exd.Incidence, complex(ptr, shift)];
            end
            exd.Position = ptr;
            exd.Shift = 0;
            assertEqual(testCase, act.Type, exd.Type);
            assertEqual(testCase, act.Transform, exd.Transform);
            assertEqual(testCase, act.Incidence, exd.Incidence);
        end
    end


%% Test Expression
    expy = testCase.TestData.Model;
    act = regression.Term.parseInputSpecs(expy, "x + movavg(y, -2) - z{+3}", @auto, @auto, @all);
    exd = testCase.TestData.Output;
    exd.Type = "Expression";
    exd.Expression = @(x,t,date__,controls__)x(1,t,:)+(((x(2,t,:))+(x(2,t-1,:)))./2)-x(3,t+3,:);
    exd.Incidence = [complex(1, 0), complex(2, 0), complex(2, -1), complex(3, 3)];
    act.Expression = func2str(act.Expression);
    exd.Expression = func2str(exd.Expression);
    assertEqual(testCase, act.Expression, exd.Expression);
    assertEqual(testCase, intersect(act.Incidence, exd.Incidence, 'stable'), act.Incidence);
    assertEqual(testCase, union(act.Incidence, exd.Incidence, 'stable'), act.Incidence);

##### SOURCE END #####
%}
