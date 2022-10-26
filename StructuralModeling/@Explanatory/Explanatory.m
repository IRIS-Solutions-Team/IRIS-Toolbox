% Explanatory  Equation with a LHS variable explained by a collection of RHS terms
%

classdef Explanatory ...
    < iris.mixin.GetterSetter ...
    & iris.mixin.CommentContainer ...
    & iris.mixin.UserDataContainer ...
    & iris.mixin.DatabankPipe ...
    & iris.mixin.Plan


    properties (Hidden)
% Fixed  Row vector of parameter values (if the parameter is fixed to that
% value) or NaNs (if the parameter can be changed or estimated)

% >=R2019b
%{
        Fixed (1, :, :) double = double.empty(1, 0, 1)
%}
% >=R2019b

% <=R2019a
%(
        Fixed double = double.empty(1, 0, 1)
%)
% <=R2019a


% Parameters  Row vector of parameter values (with parameter variants
% running in 3rd dimension) corresponding to individual regression terms
% plus the lump-sum term (if present).

% >=R2019b
%{
        Parameters (1, :, :) double = double.empty(1, 0, 1)
%}
% >=R2019b

% <=R2019a
%(
        Parameters double = double.empty(1, 0, 1)
%)
% <=R2019a


% ResidualNamePattern  Two-element string array with a prefix and a suffix
% attached to LHS variables names to create the residual name
        ResidualNamePattern (1, 2) string = ["res_", ""]


% InnovationNamePattern  Two-element string array with a prefix and a suffix
% attached to LHS variables names to create the innovation name
        InnovationNamePattern (1, 2) string = ["inn_", ""]


% FittedNamePattern  Two-element string array with a prefix and a suffix
% attached to LHS variables names to create the fitted name
        FittedNamePattern (1, 2) string = ["fit_", ""]


% LhsTransformNamePattern  Two-element string array with a prefix and a suffix
% attached to the transformed LHS variables used in regressions
        LhsTransformNamePattern (1, 2) string = ["lhs_", ""]


% ResidualModel  Armani or ParamArmani object specifying an ARMA
% model for residuals
        ResidualModel = [ ]
    end


    properties (SetAccess=protected, Hidden)
        VariableNames (1, :) string = string.empty(1, 0)
        ControlNames (1, :) string = string.empty(1, 0)
        Label (1, 1) string = ""
        Attributes (1, :) string = string.empty(1, 0)
        Include = true
        LogStatus (1, 1) logical = false
    end


    properties (Hidden)
        Context = "Explanatory"
    end


    properties (SetAccess=protected)
        FileName (1, 1) string = ""
        InputString (1, 1) string = ""
    end


    properties (SetAccess=protected, Hidden)
        Export (1, :) iris.mixin.Export = iris.mixin.Export.empty(1, 0)
        Substitutions (1, 1) struct = struct( )

        Sealed = false
        Simulate = [ ]
        EndogenizeResiduals = [ ]

% IsIdentity  True if the Explanatory object is an identity without
% residuals
        IsIdentity (1, 1) logical = false


% LinearStatus  True if the RHS is linear in parameters
        LinearStatus (1, 1) logical = false


% LhsReference  Symbol used to create lags of LHS variables (aka AR terms) on
% the RHS; each LhsReferece on the RHS must be followed by a shift
% specification in curly braces (lags are specified as negative numbers)
        LhsReference (1, 1) string = "__"


% DependentTerm  Dependent (left-hand side) term
        DependentTerm (1, :) regression.Term = regression.Term.empty(1, 0)


% ExplanatoryTerms  Array of right hand side (explanatory) terms
        ExplanatoryTerms (1, :) regression.Term = regression.Term.empty(1, 0)


% NumParameters  Number of parameters
        NumParameters (1, 1) {mustBeReal, mustBeNonnegative, mustBeInteger} = 0


% IncParameters  Incidence of parameters in nonlinear regression
% expressions
        IncParameters (1, :) logical = logical.empty(1, 0)


% Statistics  Regression statistics
        Statistics (1, 1) struct = struct( ...
            'VarResiduals', NaN ...
            , 'CovParameters', double.empty(0, 0, 1) ...
            , 'NumPeriodsFitted', NaN ...
            , 'PeriodsFitted', {{[]}} ...
            , 'ExitFlag', NaN ...
            , 'OptimOutput', {{[]}} ...
        )


        Runtime = struct( )
    end




    properties (Constant, Hidden)
        VARIABLE_WITH_SHIFT = "(?<!@)(\<[A-Za-z]\w*\>)(\{[^\}]*\})"
        VARIABLE_NO_SHIFT = "(?<!@)(\<[A-Za-z]\w*\>)(?!\()"
        USERDATA_PREFIX = "#"
    end




    properties (Dependent);
% LhsName  Databank name for the LHS variable
        LhsName

% ParameterValues  Currently assigned values of RHS parameters
        ParameterValues

% ResidualName  Databank name for the residuals
        ResidualName

% FittedName  Databank name for the fitted values of the LHS variable
        FittedName

% HasResidualModel  True if a non-identity ARIMA model for residual exists
        HasResidualModel
    end


    properties (Dependent, Hidden)
        NeedsIterate
        PosLhsName
        RhsContainsLhsName
        InnovationName
        LhsTransformName

% PlainDataNames  List of plain names in a single Explanatory object
%
%>    List of all names occurring on the LHS and RHS of the Explanatory
%>    object complemented with the `ResidualName` (ordered last in the
%>    list)
        PlainDataNames


        NumExplanatoryTerms
        MaxLag
        MaxLead
    end




    methods % Constructor
        function this = Explanatory(varargin)
            this.UserData = struct();
            if nargin==0
                return
            end
            if nargin==0 && isa(varargin{1}, 'Explanatory')
                this = varargin{1};
                return
            end
            exception.error([
                "Explanatory:InvalidContructorCall"
                "This is not a valid way to construct an Explanatory object or array. "
                "Use one of the static constructors Explanatory.fromString( ) "
                "or Explanatory.fromFile( ). "
            ]);
        end%
    end




    methods % Frontend Signatures
        %(
        varargout = alter(varargin)
        varargout = blazer(varargin)
        varargout = checkUniqueLhs(varargin)
        varargout = collectAllNames(varargin)
        varargout = collectControlNames(varargin)
        varargout = collectFittedNames(varargin)
        varargout = collectLhsNames(varargin)
        varargout = collectLogStatus(varargin)
        varargout = collectResidualNames(varargin)
        varargout = collectRhsNames(varargin)
        varargout = collectUserData(varargin)
        varargout = declareSwitches(varargin)
        varargout = defineDependentTerm(varargin)
        varargout = exclude(varargin)
        varargout = getActualMinMaxShifts(varargin)
        varargout = lookup(varargin)
        varargout = parameterizeResidualModels(varargin)
        varargout = regress(varargin)
        varargout = reset(varargin)
        varargout = residuals(varargin)
        varargout = retrieve(varargin)
        varargout = simulate(varargin)
        varargout = simulateResidualModel(varargin)
        %)
    end




    methods
        %(
        function this = addParameters(this, fixed)
            fixed = double(fixed);
            numAdd = size(fixed, 2);
            this.NumParameters = this.NumParameters + numAdd;
            numVariants = countVariants(this);
            if size(fixed, 3)==1 && numVariants>1
                fixed = repmat(fixed, 1, 1, numVariants);
            end
            this.Fixed = [this.Fixed, fixed];
            this.Parameters = [this.Parameters, fixed];
            this.Statistics.CovParameters(end+(1:numAdd), end+(1:numAdd), :) = NaN;
        end%


        function this = addExplanatoryTerm(this, fixed, inputString)
            term = regression.Term(this, inputString, "rhs");
            term = containsLhsName(term, this.PosLhsName);
            if term.ContainsCurrentLhsName
                hereReportCurrentLhsName( );
            end
            this.ExplanatoryTerms(1, end+1) = term;
            if this.LinearStatus
                this = addParameters(this, fixed);
            end
            return

                function hereReportCurrentLhsName( )
                    exception.warning([
                        "Explanatory:RhsContainsCurrentLhsName"
                        "RHS of the Explanatory object contains the current date of its own LHS name: %s "
                        "Careful because Explanatory objects are not solved as simultaneous systems. "
                    ], this.LhsName);
                end%
        end%


        function this = seal(this)
            if this.LinearStatus
                build = "";
                for i = 1 : this.NumExplanatoryTerms
                    build = build + "+p(:," + string(i) + ",v)*(" + this.ExplanatoryTerms(i).Expression + ")";
                end
                this.IncParameters = true(1, this.NumParameters);
            else
                build = this.ExplanatoryTerms.Expression;
                tokens = regexp(string(build), "\<p\((\d+)\)", "tokens");
                tokens = [tokens{:}];
                tokens = string(tokens);
                tokens = reshape(double(tokens), 1, []);
                this = addParameters(this, nan(1, max(tokens)));
                this.IncParameters = false(1, this.NumParameters);
                this.IncParameters(tokens) = true;
            end
            if ~this.IsIdentity
                this.EndogenizeResiduals = ...
                    str2func("@(x,e,p,t,v,controls__)" + this.DependentTerm.Expression + "-(" + build + ")");
                build = build + "+e(:, t, v)";
            end
            if isempty(this.DependentTerm.InverseTransform)
                invert = build;
            else
                invert = replace(this.DependentTerm.InverseTransform, "__lhs", "(" + build + ")");
                this.DependentTerm.InverseTransform = [ ];
            end
            this.Simulate = str2func("@(x,e,p,t,v,controls__)" + invert);

            for i = 1 : this.NumExplanatoryTerms
                this.ExplanatoryTerms(i).Expression = ...
                    str2func("@(x,e,p,t,v,controls__)" + this.ExplanatoryTerms(i).Expression);
            end
            this.DependentTerm.Expression = ...
                str2func("@(x,e,p,t,v,controls__)" + this.DependentTerm.Expression);
            this.Sealed = true;
        end%


        function flag = hasAttribute(this, attribute)
            attribute = strtrim(string(attribute));
            if ~isscalar(attribute) || ~startsWith(attribute, ":")
                exception.error([
                    "Explanatory:InvalidAttributeRequest"
                    "Attribute has to be a scalar string starting with a colon."
                ]);
            end
            flag = arrayfun(@(x) any(x.Attributes==attribute), this);
        end%


        function flag = hasNoAttribute(this)
            flag = arrayfun(@(x) isempty(x.Attributes), this);
        end%


        function this = removeExplanatoryTerm(this, varargin)
            numExplanatoryTerms = this.NumExplanatoryTerms;
            if numel(varargin)==1 && validated.roundScalarInRange(varargin{1}, 1, numExplanatoryTerms)
                inx = false(1, numExplanatoryTerms);
                inx(pos) = true;
            else
                term = regression.Term(this, varargin{:});
                inx = this.ExplanatoryTerms==term;
            end
            if any(inx)
                this.ExplanatoryTerms(inx) = [ ];
                this.Parameters(:, inx, :) = [ ];
                this.Statistics.CovParameters(inx, inx, :) = [ ];
                return
            end
            exception.error([
                "Explanatory:CannotFindExplanatoryTerm"
                "Cannot find the specified explanatory variable or term "
                "that is to be removed from an Explanatory model."
            ]);
        end%


        function inx = matchExplanatoryTerms(this, term)
            inx = arrayfun(@(x) isequal(term, x), this.ExplanatoryTerms);
        end%


        function pos = getPosName(this, name)
            name = replace(string(name), " ", "");
            inx = name==this.VariableNames;
            if nnz(inx)==1
                pos = find(inx);
            else
                pos = NaN;
            end
        end%
        %)
    end


    methods (Hidden)
        varargout = assignControls(varargin)
        varargout = getDataBlock(varargin)

        function flag = checkConsistency(this)
            flag = checkConsistency@iris.mixin.GetterSetter(this) ...
                   && checkConsistency@iris.mixin.UserDataContainer(this) ;
        end%


        function value = countVariants(this)
            if isempty(this)
                value = NaN;
                return
            end
            nv = arrayfun(@(x) size(x.Parameters, 3), this);
            value = max(nv);
            if all(nv==value | nv==1)
                return
            end
            exception.error([
                "Explanatory:InconsistentNumberOfVariants"
                "All Explanatory objects grouped in an array must have "
                "identical numbers of parameter variants."
            ]);
        end%


        varargout = createData4Simulate(varargin)
        varargout = createData4Regress(varargin)
        varargout = createOutputDatabank(varargin)


        function value = nameAppendables(this)
            value = [this.LhsName, this.ResidualName, this.FittedName];
            value = cellstr(value);
        end%


        varargout = runtime(varargin)
        varargout = initializeLogStatus(varargin)
        varargout = updateDataBlock(varargin)


        function this = setp(this, name, value)
            this.(name) = value;
        end%


        function value = getp(this, name)
            value = this.(name);
        end%
    end % methods


    methods (Access=protected, Hidden)
        function implementDisp(varargin)
        end%
    end % methods


    methods (Access=protected)
        varargout = checkNames(varargin)
    end % methods


    methods (Hidden) % Interface for iris.mixin.Plan
        %(
        function namesEndogenous = getEndogenousForPlan(this)
            inxIdentity = [this.IsIdentity];
            namesEndogenous = [this(~inxIdentity).LhsName];
        end%


        function namesExogenous = getExogenousForPlan(this)
            namesExogenous = string.empty(1, 0);
        end%


        function autoswaps = getAutoswapsForPlan(this)
            autoswaps = cell.empty(0, 2);
        end%


        function sigmas = getSigmasForPlan(this)
            nv = countVariants(this);
            sigmas = double.empty(0, 1, nv);
        end%
        %)
    end % methods


    methods
        function this = set.InputString(this, value)
            value = string(value);
            if ~endsWith(value, ";")
                value = value + ";";
            end
            this.InputString = value;
        end%


        function this = updateUserDataFromString(this, userDataString)
            %(
            if ~isstruct(this.UserData)
                this.UserData = struct();
            end

            userDataString = string(userDataString);
            if isempty(userDataString)
                return
            end

            userDataString = strip(userDataString);
            if strlength(userDataString)==0
                return
            end

            update = struct();
            for u = reshape(userDataString, 1, [])
                if ~endsWith(u, ";")
                    u = u + ";";
                end
                u = replace(u, this.USERDATA_PREFIX, "update.");
                eval(u);
                for n = textual.fields(update)
                    this.UserData.(n) = update.(n);
                end
            end
            %)
        end%


        function this = set.VariableNames(this, value)
            %(
            if isempty(value)
                this.VariableNames = string.empty(1, 0);
                return
            end
            if any(strlength(value)==0)
                exception.error([
                    "Explanatory:InvalidVariableNames"
                    "Variable names in an Explanatory object "
                    "must be nonempty strings."
                ]);
            end
            this.VariableNames = string(value);
            checkNames(this);
            %)
        end%


        function this = set.ControlNames(this, value)
            if isempty(value)
                this.ControlNames = string.empty(1, 0);
                return
            end
            if any(strlength(value)==0)
                exception.error([
                    "Explanatory:InvalidVariableNames"
                    "Control names in an Explanatory object "
                    "must be nonempty strings."
                ]);
            end
            this.ControlNames = unique(string(value), 'stable');
            checkNames(this);
        end%


        function this = set.ResidualNamePattern(this, value)
            %(
            locallyValidateNamePattern(value, "ResidualNamePattern");
            this.ResidualNamePattern = value;
            checkNames(this);
            %)
        end%


        function this = set.FittedNamePattern(this, value)
            %(
            locallyValidateNamePattern(value, "FittedNamePattern");
            this.FittedNamePattern = value;
            checkNames(this);
            %)
        end%


        function this = set.LhsTransformNamePattern(this, value)
            %(
            locallyValidateNamePattern(value, "LhsTransformNamePattern");
            this.LhsTransformNamePattern = value;
            checkNames(this);
            %)
        end%


        function this = set.ResidualModel(this, value)
            %(
            nv = countVariants(this);
            if isempty(value)
                this.ResidualModel = [ ];
                return
            end
            if isa(value, 'ParamArmani')
                this.ResidualModel = value;
                return
            end
            if isa(value, 'Armani')
                this.ResidualModel = value;
                return
            end
            exception.error([
                "Exception:InvalidResidualModel"
                "Invalid ResidualModel assigned to an Explanatory object. "
                "ResidualModel needs to be one of {empty, Armani, ParamArmani}."
            ]);
            %)
        end%


        function value = get.NeedsIterate(this)
            value = false(size(this));
            for i = 1 : numel(this)
                value(i) = any([this(i).DependentTerm.ContainsLaggedLhsName]) ...
                    || any([this(i).ExplanatoryTerms.ContainsLaggedLhsName]);
            end
        end%


        function value = get.PosLhsName(this)
            if isempty(this.DependentTerm)
                value = NaN;
                return
            end
            value = this.DependentTerm.Position;
        end%


        function value = get.HasResidualModel(this)
            value = false(size(this));
            for i = 1 : numel(this)
                value(i) = ~isempty(this(i).ResidualModel) && ~this(i).ResidualModel.IsIdentity;
            end
        end%


        function value = get.MaxLag(this)
            value = min([this.DependentTerm.MinShift, this.ExplanatoryTerms(:).MinShift]);
            value = min(0, value);
        end%


        function value = get.MaxLead(this)
            value = max([this.DependentTerm.MaxShift, this.ExplanatoryTerms(:).MaxShift]);
            value = max(0, value);
        end%


        function value = get.LhsName(this)
            if isempty(this.VariableNames)
                value = "";
                return
            end
            posLhsName = this.PosLhsName;
            if ~isscalar(posLhsName) || ~isfinite(posLhsName)
                value = "";
                return
            end
            value = this.VariableNames(posLhsName);
        end%


        function get.ParameterValues(this)
            value = this.Parameters;
        end%


        function value = get.RhsContainsLhsName(this)
            value = any([this.ExplanatoryTerms.ContainsLhsName]);
        end%


        function value = get.ResidualName(this)
            if this.IsIdentity
                value = string.empty(1, 0);
                return
            end
            value = this.ResidualNamePattern(1) + this.LhsName + this.ResidualNamePattern(2);
        end%


        function value = get.InnovationName(this)
            if this.IsIdentity
                value = string.empty(1, 0);
                return
            end
            value = this.InnovationNamePattern(1) + this.LhsName + this.InnovationNamePattern(2);
        end%


        function value = get.FittedName(this)
            if this.IsIdentity
                value = string.empty(1, 0);
                return
            end
            value = this.FittedNamePattern(1) + this.LhsName + this.FittedNamePattern(2);
        end%


        function value = get.LhsTransformName(this)
            if this.IsIdentity
                value = string.empty(1, 0);
                return
            end
            value = this.LhsTransformNamePattern(1) + this.LhsName + this.LhsTransformNamePattern(2);
        end%


        function value = get.NumExplanatoryTerms(this)
            value = numel(this.ExplanatoryTerms);
        end%
    end




    methods (Static)
        varargout = fromString(varargin)
        varargout = fromFile(varargin)
        varargout = fromModel(varargin)
    end




    methods (Static, Hidden)
        varargout = postparse(varargin)


        function [label, userDataString] = extractUserDataString(label)
            %(
            USERDATA_PREFIX = Explanatory.USERDATA_PREFIX;
            if ~contains(label, USERDATA_PREFIX)
                userDataString = "";
                return
            end
            userDataString = eraseBetween(label, 1, USERDATA_PREFIX);
            label = extractBefore(label, USERDATA_PREFIX);
            %)
        end%


        function [inputString, label] = extractLabel(inputString)
            %(
            label = "";
            inputString = strip(inputString);
            pos = strfind(inputString, '"');
            if numel(pos)<2 || pos(1)~=1
                pos = strfind(inputString, "'");
                if numel(pos)<2 || pos(1)~=1
                    return
                end
            end
            label = extractBetween( ...
                inputString, pos(1), pos(2), ...
                'Boundaries', 'Exclusive' ...
            );
            inputString = eraseBetween( ...
                inputString, pos(1), pos(2), ...
                'Boundaries', 'Inclusive' ...
            );
            label = strip(string(label));
            %)
        end%


        function [inputString, attributes] = extractAttributes(inputString)
            %(
            attributes = string.empty(1, 0);
            inputString = strtrim(inputString);
            if ~startsWith(inputString, ':')
                return
            end
            [attributes, start, finish] = regexp(inputString, '^((:\w+)\s*)+', 'Tokens', 'Start', 'End', 'Once');
            if isempty(attributes)
                return
            end
            attributes = strtrim(split(attributes));
            attributes(attributes=="") = [ ];
            attributes = reshape(attributes, 1, [ ]);
            inputString = eraseBetween(inputString, start, finish, 'Boundaries', 'Inclusive');
            inputString = strtrim(inputString);
            %)
        end%


        function validateBlackout(input, this)
            %(
            if iscell(input)
                try
                    input = [input{:}];
                catch
                    input = NaN;
                end
            end
            if isnumeric(input) && ~any(isnan(input(:))) ...
                    && (nargin>=2 && (isscalar(input) || numel(input)==numel(this)))
                return
            end
            error("Validation:Failed", "Input value must be a scalar date or an array of dates the same size as the Explanatory array");
            %)
        end%


        function blackout = resolveBlackout(blackout)
            %(
            if iscell(blackout)
                blackout = [blackout{:}];
            end
            blackout = reshape(double(blackout), 1, []);
            %)
        end%
    end
end

%
% Local Validators
%

function locallyValidateNamePattern(value, prop)
    if ~isstring(value) || ~isequal(size(value), [1, 2])
        exception.error([
            "Explanatory:InvalidNamePattern"
            prop + " must be a 1-by-2 string consisting of the prefix and the suffix."
        ]);
    end
    if all(strlength(value)==0)
        exception.error([
            "Explanatory:InvalidNamePattern"
            "Either the prefix or the suffix (or both) for the new " + prop
            "must be a non-empty string."
        ]);
    end
end%

