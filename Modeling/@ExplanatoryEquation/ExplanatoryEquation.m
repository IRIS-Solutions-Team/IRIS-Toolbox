% ExplanatoryEquation  Equation with a LHS variable explained by RHS terms
%

classdef ExplanatoryEquation ...
    < shared.GetterSetter ...
    & shared.UserDataContainer ...
    & shared.CommentContainer ...
    & shared.DatabankPipe


    properties
        VariableNames (1, :) string = string.empty(1, 0)
        ResidualPrefix = "res_"
        FittedPrefix = "fit_"
        Label (1, 1) string = ""
        Attributes (1, :) string = string.empty(1, 0)
        RaggedEdge (1, 1) logical = false
    end




    properties (Hidden)
        Context = "ExplanatoryEquation"
    end




    properties (SetAccess=protected)
        FileName (1, 1) string = ""
        InputString (1, 1) string = ""
        Export (1, :) shared.Export = shared.Export.empty(1, 0)
        Substitutions (1, 1) struct = struct( )

        Dependent (1, :) regression.Term = regression.Term.empty(1, 0)
        Explanatory (1, :) regression.Term = regression.Term.empty(1, 0)
        Parameters (1, :, :) double = double.empty(1, 0, 1)
        Statistics (1, 1) struct = struct( 'VarResiduals', NaN, ...
                                           'CovParameters', double.empty(0, 0, 1) )

        Runtime = struct( )
    end




    properties (Dependent)
        FreeParameters
        PosOfLhsName
        RhsContainsLhsName
        LhsName
        ResidualName
        FittedName
        PlainDataNames
        NumOfExplanatory
        NumOfParameters
        MaxLag
        MaxLead
    end




    methods
        function this = ExplanatoryEquation(varargin)
            if nargin==0
                return
            end
            if nargin==0 && isa(varargin{1}, 'ExplanatoryEquation')
                this = varargin{1};
                return
            end
        end%
    end




    methods % Frontend Signatures
        %(
        varargout = alter(varargin)
        varargout = blazer(varargin)
        varargout = defineDependent(varargin)
        varargout = regress(varargin)
        varargout = simulate(varargin)
        varargout = residuals(varargin)
        %)
    end




    methods % Frontend Definitions
        %(
        function this = addExplanatory(this, varargin)
            term = regression.Term(this, varargin{:});
            this.Explanatory(1, end+1) = term;
            this.Parameters(:, end+1, :) = term.Fixed;
            this.Statistics.CovParameters(end+1, end+1, :) = NaN;
        end%




        function flag = hasAttribute(this, attribute)
            attribute = strtrim(string(attribute));
            if ~isscalar(attribute) || ~startsWith(attribute, ":")
                thisError = [ 
                    "ExplanatoryEquation:InvalidAttributeRequest"
                    "Attribute has to be a scalar string starting with a colon." 
                ];
                throw(exception.Base(thisError, 'error'));
            end
            flag = arrayfun(@(x) any(x.Attributes==attribute), this);
        end%




        function this = removeExplanatory(this, varargin)
            numExplanatory = this.NumOfExplanatory;
            if numel(varargin)==1 && validated.roundScalarInRange(varargin{1}, 1, numExplanatory)
                inx = false(1, numExplanatory);
                inx(pos) = true;
            else
                term = regression.Term(this, varargin{:});
                inx = this.Explanatory==term;
            end
            if any(inx)
                this.Explanatory(inx) = [ ];
                this.Parameters(:, inx, :) = [ ];
                this.Statistics.CovParameters(inx, inx, :) = [ ];
                return
            end
            thisError = [ 
                "ExplanatoryEquation:CannotFindExplanatory"
                "Cannot find the specified explanatory variable or term "
                "that is to be removed from an ExplanatoryEquation model."
            ];
            throw(exception.Base(thisError, 'error'));
        end%




        function inx = matchExplanatorySpecs(this, term)
            numExplanatory = this.NumOfExplanatory;
            inx = false(1, numExplanatory);
            for i = 1 : numExplanatory
                inx(i) = isequal(term, this.Explanatory(i, :));
            end
        end%



        
        function pos = getPositionOfName(this, name)
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
        varargout = collectAllNames(varargin)
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
            value = nv(1);
            if all(nv==value)
                return
            end
            thisError = [ 
                "ExplanatoryEquation:InconsistentNumberOfVariants"
                "All ExplanatoryEquation objects grouped in an array must have "
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
        varargout = updateDataBlock(varargin)
    end




    methods (Access=protected, Hidden)
        function implementDisp(varargin)
        end%
    end




    methods (Access=protected)
        function checkNames(this)
            checkList = [this.VariableNames, this.ResidualName];
            nameConflicts = parser.getMultiple(checkList);
            if ~isempty(nameConflicts)
                nameConflicts = cellstr(nameConflicts);
                thisError = [ 
                    "ExplanatoryEquation:MultipleNames"
                    "This name is declared more than once "
                    "in an ExplanatoryEquation object: %s "
                ];
                throw( exception.Base(thisError, 'error'), ...
                       nameConflicts{:} );
            end
            inxValid = arrayfun(@isvarname, checkList);
            if any(~inxValid)
                thisError = [ 
                    "ExplanatoryEquation:InvalidName"
                    "This name in an ExplanatoryEquation object "
                    "is not a valid Matlab name: %s"
                ];
                throw(exception.Base(thisError, 'error'), checkList{~inxValid});
            end
        end%
    end




    methods
        function this = set.Dependent(this, term)
            if ~isscalar(term)
                thisError = [ 
                    "ExplanatoryEquation:InvalidDependent"
                    "Only one Dependent (LHS) term can be specified "
                    "in an ExplanatoryEquation object." 
                ];
                throw(exception.Base(thisError, "error"));
            end
            if ~isempty(term.Expression)
                thisError = [ 
                    "ExplanatoryEquation:InvalidDependent"
                    "Invalid specification of the Dependent (LHS) term "
                    "in an ExplanatoryEqution object."
                ];
                throw(exception.Base(thisError, "error"));
            end
            if term.Shift~=0
                thisError = [ 
                    "ExplanatoryEquation:InvalidDependent"
                    "Depedent (LHS) term in an ExplanatoryEquation objection "
                    "is not allowed with a time shift (lag or lead). "
                ];
                throw(exception.Base(thisError, 'error'));
            end
            term.Fixed = 1;
            term.ContainsLhsName = true;
            this.Dependent = term;
        end%




        function this = set.VariableNames(this, value)
            if isempty(value)
                % Remove VariableNames from arrays with more than one
                % element in positions 2 and higher.
                this.VariableNames = string.empty(1, 0);
                return
            end
            if any(strlength(value)==0)
                thisError = [ 
                    "ExplanatoryEquation:InvalidVariableNames"
                    "Variable names in an ExplanatoryEquation object "
                    "must be nonempty strings."
                ];
                throw(exception.Base(thisError, 'error'));
            end
            this.VariableNames = string(value);
            checkNames(this);
        end%




        function value = get.FreeParameters(this)
            value = this.Parameters(:, isnan([this.Explanatory(:).Fixed]), :);
        end%




        function this = set.FreeParameters(this, value)
            nv = countVariants(this);
            numValues = size(value, 3);
            if nv>1 && numValues==1
                value = repmat(value, 1, 1, nv);
            end
            this.Parameters(:, isnan([this.Explanatory(:).Fixed]), :) = value;
        end%




        function value = get.PosOfLhsName(this)
            if isempty(this.Dependent)
                value = double.empty(1, 0);
                return
            end
            value = this.Dependent.Position;
        end%




        function value = get.MaxLag(this)
            allMaxLags = [this.Explanatory.MinShift];
            value = min(allMaxLags);
            value = min(0, value);
        end%




        function value = get.MaxLead(this)
            allMaxLeads = [this.Explanatory.MaxShift];
            value = max(allMaxLeads);
            value = max(0, value);
        end%




        function value = get.LhsName(this)
            value = this.VariableNames(this.PosOfLhsName);
        end%




        function value = get.RhsContainsLhsName(this)
            value = any([this.Explanatory.ContainsLhsName]);
        end%




        function value = get.ResidualName(this)
            value = this.ResidualPrefix + this.LhsName;
        end%




        function value = get.FittedName(this)
            value = this.FittedPrefix + this.LhsName;
        end%




        function value = get.PlainDataNames(this)
                value = [this.VariableNames, this.ResidualName];
        end%




        function value = get.NumOfExplanatory(this)
            value = numel(this.Explanatory);
        end%




        function value = get.NumOfParameters(this)
            value = this.NumOfExplanatory;
        end%
    end




    methods (Static)
        varargout = fromString(varargin)
        varargout = fromFile(varargin)
        varargout = fromModel(varargin)


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

