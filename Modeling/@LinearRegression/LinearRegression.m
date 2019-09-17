% LinearRegression  Single-Equation Linear Regression Model
%

classdef LinearRegression < shared.GetterSetter ...
                          & shared.UserDataContainer ...
                          & shared.CommentContainer ...
                          & shared.DatabankPipe


    properties
        LhsName (1, 1) string = "x"
        RhsNames (1, :) string = string.empty(1, 0);
        Intercept (1, 1) logical = false
        ErrorsPrefix = "res_"
        FittedPrefix = "fit_"
    end




    properties (SetAccess=protected)
        Dependent (1, 1) regression.Term = regression.Term( )
        Explanatory (1, :) regression.Term = regression.Term.empty(1, 0)
        Parameters (1, :, :) double = double.empty(1, 0, 1)
        Statistics (1, 1) struct = struct( 'VarErrors', NaN, ...
                                           'CovParameters', double.empty(0, 0, 1) );
    end




    properties (Dependent)
        ErrorsName
        FittedName
        ExplanatoryNames
        LhsNameInDatabank
        ErrorsNameInDatabank
        FittedNameInDatabank
        ExplanatoryNamesInDatabank
        PosOfLhsNames
        NumOfLhsNames
        NumOfExplanatory
        NumOfLines
        NumOfParameters
        NumOfVariants
        NamesOfAppendables
        MaxLag
        MaxLead
    end




    methods
        function this = LinearRegression(varargin)
            if nargin==0
                return
            end
            if nargin==0 && isa(varargin{1}, 'LinearRegression')
                this = varargin{1};
                return
            end
        end%
    end




    methods




        function this = addExplanatory(this, varargin)
            term = regression.Term(this, varargin{:});
            this.Explanatory(1, end+1) = term;
        end%




        function this = removeExplanatory(this, varargin)
            term = regression.Term(this, varargin{:});
            inx = this.Explanatory==term;
            if any(inx)
                this.Explanatory(inx) = [ ];
                return
            end
            thisError = { 'LinearRegression:CannotFindExplanatory'
                          'Cannot find the LinearRegression explanatory variable to be removed '};
            throw( exception.Base(thisError, 'error') );
        end%




        function inx = matchExplanatorySpecs(this, term)
            numExplanatory = this.NumOfExplanatory;
            inx = false(1, numExplanatory);
            for i = 1 : numExplanatory
                inx(i) = isequal(term, this.Explanatory(i, :));
            end
        end%



        
        function pos = getPositionOfName(this, name)
            name = strtrim(name);
            inx = strcmp(name, this.ExplanatoryNames);
            if nnz(inx)==1
                pos = find(inx);
            else
                pos = NaN;
            end
        end%




        varargout = createModelData(varargin)
        varargout = estimate(varargin)
        varargout = simulate(varargin)
    end




    methods (Hidden)
        function flag = checkConsistency(this)
            flag = checkConsistency@shared.GetterSetter(this) ...
                   && checkConsistency@shared.UserDataContainer(this) ;
        end%
    end




    methods (Access=protected, Hidden)
        varargout = getPlainData(varargin)


        function implementDisp(varargin)
        end%
    end




    methods (Access=protected)
        function checkNames(this)
            checkList = [this.LhsName, this.RhsNames, this.ErrorsName];
            nameConflicts = parser.getMultiple(checkList);
            if ~isempty(nameConflicts)
                nameConflicts = cellstr(nameConflicts);
                thisError = { 'LinearRegression:MultipleNames'
                              'This name is declared more than once in the LinearRegression object: %s '};
                throw( exception.Base(thisError, 'error'), ...
                       nameConflicts{:} );
            end
            inxValid = arrayfun(@isvarname, checkList);
            if any(~inxValid)
                thisError = { 'LinearRegression:InvalidName'
                              'This LinearRegression name is not a valid Matlab name: %s'};
                throw( exception.Base(thisError, 'error'), ...
                       checkList{~inxValid} );
            end
        end%
    end




    methods
        function this = set.Dependent(this, term)
            if ~term.ContainsLhsName || ~isempty(term.Expression) || term.Shift~=0
                thisError = { 'LinearRegression:InvalidDependent'
                              'Invalid specification of dependent variable in LinearRegression' };
                throw( exception.Base(thisError, 'error') );
            end
            this.Dependent = term;
        end%




        function this = set.Explanatory(this, value)
            this.Explanatory = value;
            this.Parameters = nan(1, this.NumOfParameters, this.NumOfVariants);
        end%




        function this = set.Intercept(this, value)
            this.Intercept = isequal(value, true);
            this.Parameters = nan(1, this.NumOfParameters, this.NumOfVariants);
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




        function value = get.LhsNameInDatabank(this)
            lhsNameInDatabank = substituteNamesInDatabank(this, this.LhsName);
            value = string(lhsNameInDatabank);
        end%




        function this = set.LhsName(this, value)
            if ~isscalar(value) || strlength(value)==0
                thisError = { 'LinearRegression:InvalidLhsName'
                              'LHS name in a LinearRegression must be a scalar nonempty string' };
                throw( exception.Base(thisError, 'error') );
            end
            this.LhsName = value;
            checkNames(this);
        end%




        function value = get.NumOfLhsNames(this)
            value = 1;
        end%




        function value = get.PosOfLhsNames(this)
            value = 1;
        end%




        function this = set.RhsNames(this, value)
            if any(strlength(value)==0)
                thisError = { 'LinearRegression:InvalidLhsName'
                              'RHS names in a LinearRegression must be nonempty strings' };
                throw( exception.Base(thisError, 'error') );
            end
            this.RhsNames = string(value);
            checkNames(this);
        end%




        function value = get.ErrorsName(this)
            value = this.ErrorsPrefix + this.LhsName;
        end%




        function value = get.ErrorsNameInDatabank(this)
            lhsNameInDatabank = substituteNamesInDatabank(this, this.LhsName);
            value = this.ErrorsPrefix + string(lhsNameInDatabank);
        end%




        function value = get.FittedName(this)
            value = this.FittedPrefix + this.LhsName;
        end%




        function value = get.FittedNameInDatabank(this)
            lhsNameInDatabank = substituteNamesInDatabank(this, this.LhsName);
            value = this.FittedPrefix + string(lhsNameInDatabank);
        end%




        function value = get.ExplanatoryNames(this)
            value = [this.LhsName, this.RhsNames];
        end%




        function value = get.ExplanatoryNamesInDatabank(this)
            names = [this.LhsName, this.RhsNames];
            names = substituteNamesInDatabank(this, names);
            value = string(names);
        end%




        function value = get.NumOfExplanatory(this)
            value = numel(this.Explanatory);
        end%




        function value = get.NumOfLines(this)
            value = nnz(this.Intercept);
        end%




        function value = get.NumOfParameters(this)
            value = this.NumOfExplanatory + this.NumOfLines;
        end%




        function value = get.NumOfVariants(this)
            value = size(this.Parameters, 3);
        end%




        function list = get.NamesOfAppendables(this)
            list = [this.LhsName, this.ErrorsName];
        end%
    end




    methods (Static)
        varargout = fromString(varargin)
    end
end

