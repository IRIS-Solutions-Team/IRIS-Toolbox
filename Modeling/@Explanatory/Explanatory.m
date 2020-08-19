% Explanatory  Equation with a LHS variable explained by a collection of RHS terms
%

classdef Explanatory ...
    < shared.GetterSetter ...
    & shared.UserDataContainer ...
    & shared.CommentContainer ...
    & shared.DatabankPipe ...
    & shared.Plan


    properties
        Fixed (1, :, :) double = double.empty(1, 0, 1)


% Parameters  Row vector of parameter values (with parameter variants
% running in 3rd dimension) corresponding to individual regression terms
% plus the lump-sum term (if present).
        Parameters (1, :, :) double = double.empty(1, 0, 1)


% ResidualNamePattern  Two-element string array with a prefix and a suffix
% attached to LHS variables names to create the residual name
        ResidualNamePattern (1, 2) string = ["res_", ""]


% FittedNamePattern  Two-element string array with a prefix and a suffix
% attached to LHS variables names to create the fitted name
        FittedNamePattern (1, 2) string = ["fit_", ""]


% ResidualModel  Armani or ParameterizedArmani object specifying an ARMA
% model for residuals
        ResidualModel = [ ]


% ResidualModelParameters  Parameters in residual model
        ResidualModelParameters (1, :, :) double = double.empty(1, 0, 1)
    end


    properties (SetAccess=protected)
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
        Export (1, :) shared.Export = shared.Export.empty(1, 0)
        Substitutions (1, 1) struct = struct( )

        Sealed = false
        Simulate = [ ]
        EndogenizeResiduals = [ ]

% IsIdentity  True if the Explanatory object is an identity without
% residuals
        IsIdentity (1, 1) logical = false


% LhsReference  Symbol used to create lags of LHS variables (aka AR terms) on
% the RHS; each LhsReferece on the RHS must be followed by a shift
% specification in curly braces (lags are specified as negative numbers)
        LhsReference (1, 1) string = "__"


% DependentTerm  Dependent (left-hand side) term
        DependentTerm (1, :) regression.Term = regression.Term.empty(1, 0)


% ExplanatoryTerms  Array of right hand side (explanatory) terms
        ExplanatoryTerms (1, :) regression.Term = regression.Term.empty(1, 0)


        Statistics (1, 1) struct = struct( 'VarResiduals', NaN, ...
                                           'CovParameters', double.empty(0, 0, 1) )

        Runtime = struct( )
    end




    properties (Constant)
        VARIABLE_WITH_SHIFT = "(?<!@)(\<[A-Za-z]\w*\>)(\{[^\}]*\})"
        VARIABLE_NO_SHIFT   = "(?<!@)(\<[A-Za-z]\w*\>)(?!\()" 
    end




    properties (Dependent)
        NeedsIterate
        PosLhsName
        RhsContainsLhsName
        LhsName
        ResidualName
        FittedName

% PlainDataNames  List of plain names in a single Explanatory object
%
%>    List of all names occurring on the LHS and RHS of the Explanatory
%>    object complemented with the `ResidualName` (ordered last in the
%>    list)
        PlainDataNames


% HasResidualModel  True if a non-identity ARIMA model for residual exists
        HasResidualModel


        NumExplanatoryTerms
        NumParameters
        MaxLag
        MaxLead
    end




    methods % Constructor
        function this = Explanatory(varargin)
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
        varargout = collectAllNames(varargin)
        varargout = collectControlNames(varargin)
        varargout = collectLhsNames(varargin)
        varargout = collectRhsNames(varargin)
        varargout = collectLogStatus(varargin)
        varargout = checkUniqueLhs(varargin)
        varargout = declareSwitches(varargin)
        varargout = defineDependentTerm(varargin)
        varargout = retrieve(varargin)
        varargout = getActualMinMaxShifts(varargin)
        varargout = lookup(varargin)
        varargout = parameterizeResidualModels(varargin)
        varargout = regress(varargin)
        varargout = simulate(varargin)
        varargout = simulateResidualModel(varargin)
        varargout = residuals(varargin)
        %)
    end




    methods 
        %(
        function this = addExplanatoryTerm(this, fixed, inputString)
            term = regression.Term(this, inputString, "rhs");
            term = containsLhsName(term, this.PosLhsName);
            if term.ContainsCurrentLhsName
                hereReportCurrentLhsName( );
            end
            this.ExplanatoryTerms(1, end+1) = term;
            this.Fixed(:, end+1, :) = double(fixed);
            this.Parameters(:, end+1, :) = double(fixed);
            if isempty(fixed) || numel(this.Parameters)~=numel(this.ExplanatoryTerms)
                keyboard
            end
            this.Statistics.CovParameters(end+1, end+1, :) = NaN;
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
            build = "";
            for i = 1 : this.NumExplanatoryTerms
                build = build + "+p(:," + string(i) + ",v)*(" + this.ExplanatoryTerms(i).Expression + ")";
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
            flag = checkConsistency@shared.GetterSetter(this) ...
                   && checkConsistency@shared.UserDataContainer(this) ;
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
    end




    methods (Access=protected, Hidden)
        function implementDisp(varargin)
        end%
    end




    methods (Access=protected)
        varargout = checkNames(varargin)


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
    end


    methods
        function this = set.VariableNames(this, value)
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
            if all(strlength(value)==0)
                thisError = [
                    "Explanatory:InvalidResidualNamePattern"
                    "Either the prefix or the suffix (or both) for the new ResidualNamePattern"
                    "must be a non-empty string."
                ];
            end
            [this.ResidualNamePattern] = deal(value);
            checkNames(this);
            %)
        end%


        function this = set.FittedNamePattern(this, value)
            %(
            if all(strlength(value)==0)
                thisError = [
                    "Explanatory:InvalidFittedNamePattern"
                    "Either the prefix or the suffix (or both) for the new FittedNamePattern"
                    "must be a non-empty string."
                ];
            end
            [this.FittedNamePattern] = deal(value);
            checkNames(this);
            %)
        end%


        function this = set.Parameters(this, value)
            %(
            if ~isnumeric(value)
                exception.error([
                    "Explanatory:InvalidParametersAssigned"
                    "Parameters in Explanatory objects must be numeric values"
                ]);
            end
            for i = 1 : numel(this)
                numTerms = numel(this(i).ExplanatoryTerms);
                if size(value, 2)~=numTerms
                    exception.error([
                        "Explanatory:InvalidParametersAssigned"
                        "Invalid dimension of parameters assigned to Explanatory object:"
                        "there are %g explanatory term(s) and %g value(s) being assigned."
                    ], numTerms, size(value, 2));
                end
                this(i).Parameters = value;
            end
            %)
        end%


        function this = set.Fixed(this, value)
            %(
            if ~isnumeric(value)
                exception.error([
                    "Explanatory:InvalidFixedAssigned"
                    "Fixed parameters in Explanatory objects must be numeric values"
                ]);
            end
            this.Fixed = value;
            numTerms = numel(this.ExplanatoryTerms);
            if size(this.Fixed, 2)~=numTerms
                exception.error([
                    "Explanatory:InvalidFixedParametersAssigned"
                    "Invalid dimension of fixed parameters assigned to Explanatory object:"
                    "there are %g explanatory term(s) and %g parameter variant(s)."
                ], numTerms, countVariants(this));
            end
            %)
        end%


        function this = set.ResidualModel(this, value)
            %(
            nv = countVariants(this);
            if isempty(value)
                this.ResidualModel = [ ];
                this.ResidualModelParameters = double.empty(1, 0, nv);
                return
            end
            if isa(value, "ParameterizedArmani")
                this.ResidualModel = value;
                this.ResidualModelParameters = nan(1, value.NumParameters, nv);
                return
            end
            if isa(value, "Armani")
                this.ResidualModel = value;
                this.ResidualModelParameters = double.empty(1, 0, nv);
                return
            end
            exception.error([
                "Exception:InvalidResidualModel"
                "Invalid ResidualModel assigned to an Explanatory object. "
                "ResidualModel needs to be one of {empty, Armani, ParameterizedArmani}."
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




        function value = get.FittedName(this)
            if this.IsIdentity
                value = string.empty(1, 0);
                return
            end
            value = this.FittedNamePattern(1) + this.LhsName + this.FittedNamePattern(2);
        end%




        function value = get.NumExplanatoryTerms(this)
            value = numel(this.ExplanatoryTerms);
        end%




        function value = get.NumParameters(this)
            value = this.NumExplanatoryTerms;
        end%
    end




    methods (Static)
        varargout = fromString(varargin)
        varargout = fromFile(varargin)
        varargout = fromModel(varargin)
    end




    methods (Static, Hidden)
        varargout = postparse(varargin)


        function [inputString, label] = extractLabel(inputString)
            label = "";
            inputString = strtrim(inputString);
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
            label = string(label);
        end%




        function [inputString, attributes] = extractAttributes(inputString)
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
        end%
    end
end

