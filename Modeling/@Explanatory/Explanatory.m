% Explanatory  Equation with a LHS variable explained by a collection of RHS terms
%

classdef Explanatory ...
    < shared.GetterSetter ...
    & shared.UserDataContainer ...
    & shared.CommentContainer ...
    & shared.DatabankPipe ...
    & shared.Plan


    properties (SetAccess=protected)
        VariableNames (1, :) string = string.empty(1, 0)
        ControlNames (1, :) string = string.empty(1, 0)
        Label (1, 1) string = ""
        Attributes (1, :) string = string.empty(1, 0)
        RaggedEdge (1, 1) logical = false
        Include = true
        Parameters (1, :, :) double = double.empty(1, 0, 1)
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

        IsIdentity (1, 1) logical = false


% ResidualNamePattern  Two-element string array with a prefix and a suffix
% attached to LHS variables names to create the residual name
        ResidualNamePattern (1, 2) string = ["res_", ""]


% FittedNamePattern  Two-element string array with a prefix and a suffix
% attached to LHS variables names to create the fitted name
        FittedNamePattern (1, 2) string = ["fit_", ""]


% DateReference  Name under which the current date is accessible at runtime
        DateReference (1, 1) string = "date__"


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
        FreeParameters
        PosLhsName
        RhsContainsLhsName
        LhsName
        ResidualName
        FittedName
        PlainDataNames
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
            thisError = [ "Explanatory:InvalidContructorCall"
                          "This is not a valid way to construct an Explanatory object or array. "
                          "Use one of the static constructors Explanatory.fromString( ) "
                          "or Explanatory.fromFile( ). " ];
            throw(exception.Base(thisError, 'error'));
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
        varargout = regress(varargin)
        varargout = simulate(varargin)
        varargout = residuals(varargin)
        %)
    end




    methods % Frontend Definitions
        %(
        function this = addExplanatoryTerm(this, varargin)
            term = regression.Term(this, varargin{:});
            term.ContainsLhsName = containsLhsName(term, this);
            this.ExplanatoryTerms(1, end+1) = term;
            this.Parameters(:, end+1, :) = term.Fixed;
            this.Statistics.CovParameters(end+1, end+1, :) = NaN;
        end%




        function flag = hasAttribute(this, attribute)
            attribute = strtrim(string(attribute));
            if ~isscalar(attribute) || ~startsWith(attribute, ":")
                thisError = [ 
                    "Explanatory:InvalidAttributeRequest"
                    "Attribute has to be a scalar string starting with a colon." 
                ];
                throw(exception.Base(thisError, 'error'));
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
            thisError = [ 
                "Explanatory:CannotFindExplanatoryTerm"
                "Cannot find the specified explanatory variable or term "
                "that is to be removed from an Explanatory model."
            ];
            throw(exception.Base(thisError, 'error'));
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
            thisError = [ 
                "Explanatory:InconsistentNumberOfVariants"
                "All Explanatory objects grouped in an array must have "
                "identical numbers of parameter variants." 
            ];
            throw(exception.Base(thisError, 'error'));
        end%


        varargout = createModelData(varargin)
        varargout = createOutputDatabank(varargin)


        function value = nameAppendables(this)
            value = [this.LhsName, this.ResidualName, this.FittedName];
            value = cellstr(value);
        end%


        varargout = runtime(varargin)
        varargout = initializeLogStatus(varargin)
        varargout = updateDataBlock(varargin)
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
        function this = set.DependentTerm(this, term)
            if ~isscalar(term)
                thisError = [ 
                    "Explanatory:InvalidDependentTerm"
                    "Only one DependentTerm can be specified "
                    "in an Explanatory object." 
                ];
                throw(exception.Base(thisError, "error"));
            end
            if ~isempty(term.Expression)
                thisError = [ 
                    "Explanatory:InvalidDependentTerm"
                    "Invalid specification of the DependentTerm "
                    "in an ExplanatoryEqution object."
                ];
                throw(exception.Base(thisError, "error"));
            end
            if term.Shift~=0
                thisError = [ 
                    "Explanatory:InvalidDependentTerm"
                    "Depedent term in an Explanatory objection "
                    "is not allowed with a time shift (lag or lead). "
                ];
                throw(exception.Base(thisError, 'error'));
            end
            term.Fixed = 1;
            term.ContainsLhsName = true;
            this.DependentTerm = term;
        end%




        function this = set.VariableNames(this, value)
            if isempty(value)
                this.VariableNames = string.empty(1, 0);
                return
            end
            if any(strlength(value)==0)
                thisError = [ 
                    "Explanatory:InvalidVariableNames"
                    "Variable names in an Explanatory object "
                    "must be nonempty strings."
                ];
                throw(exception.Base(thisError, 'error'));
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
                thisError = [ 
                    "Explanatory:InvalidVariableNames"
                    "Control names in an Explanatory object "
                    "must be nonempty strings."
                ];
                throw(exception.Base(thisError, 'error'));
            end
            this.ControlNames = unique(string(value), 'stable');
            checkNames(this);
        end%




        function this = set.ResidualNamePattern(this, value)
            this.ResidualNamePattern = value;
            checkNames(this);
        end%




        function this = set.FittedNamePattern(this, value)
            this.FittedNamePattern = value;
            checkNames(this);
        end%




        function value = get.NeedsIterate(this)
            value = false(size(this));
            for i = 1 : numel(this)
                value(i) = startsWith(this(i).DependentTerm.Transform, "diff") ...
                    || any([this(i).ExplanatoryTerms.ContainsLhsName]);
            end
        end%




        function value = get.FreeParameters(this)
            value = this.Parameters(:, isnan([this.ExplanatoryTerms(:).Fixed]), :);
        end%




        function this = set.FreeParameters(this, value)
            nv = countVariants(this);
            numValues = size(value, 3);
            if nv>1 && numValues==1
                value = repmat(value, 1, 1, nv);
            end
            this.Parameters(:, isnan([this.ExplanatoryTerms(:).Fixed]), :) = value;
        end%




        function value = get.PosLhsName(this)
            if isempty(this.DependentTerm)
                value = NaN;
                return
            end
            value = this.DependentTerm.Position;
        end%




        function value = get.MaxLag(this)
            allMaxLags = [this.ExplanatoryTerms.MinShift];
            value = min(allMaxLags);
            value = min(0, value);
        end%




        function value = get.MaxLead(this)
            allMaxLeads = [this.ExplanatoryTerms.MaxShift];
            value = max(allMaxLeads);
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




        function value = get.PlainDataNames(this)
                value = [this.VariableNames, this.ResidualName];
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

