% BaseVAR  Superclass for VAR based model objects
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

classdef (CaseInsensitiveProperties=true) ...
    BaseVAR ...
    < matlab.mixin.CustomDisplay ...
    & iris.mixin.UserDataContainer ...
    & iris.mixin.CommentContainer ...
    & iris.mixin.GetterSetter ...
    & iris.mixin.DatabankPipe

    properties
        % Tolerance  Tolerance level object
        Tolerance (1, 1) iris.mixin.Tolerance = iris.mixin.Tolerance()

        % EndogenousNames  Names of endogenous variables
        EndogenousNames (1, :) string = string.empty(1, 0)

        % ResidualNames  Names of forecast errors
        ResidualNames (1, :) string = string.empty(1, 0)

        % ExogenouskNames  Names of exogenous variables
        ExogenousNames (1, :) string = string.empty(1, 0)

        % ConditioningNames  Names of conditioning variables
        ConditioningNames (1, :) string = string.empty(1, 0)

        % IEqtn  Expressions for conditioning variables
        ConditiontingEquations (1, :) string = string.empty(1, 0)

        Intercept (1, 1) logical = true

        Order (1, 1) double = 1

        % A  Transition matrices with higher orders concatenated horizontally
        A = double.empty(0)

        % K  Vector of intercepts (constant terms)
        K = double.empty(0, 1)

        T = [] % Schur quasitriangular matrix
        U = [] % Schur unitary matrix

        % Zi  Measurement matrx for conditioning variables
        Zi = double.empty(0)

        % X0  Asymptotic mean assumption for exogenous variables
        X0 = zeros(0, 1)

        % J  Impact matrix of exogenous variables
        J = zeros(0)

        % Omega  Covariance matrix of reduced-form forecast errors
        Omega = double.empty(0)

        EigVal = double.empty(1, 0) % Eigenvalues

        % EigenStability  Stability indicator for each eigenvalue
        EigenStability = int8.empty(1, 0)

        % Range  Estimation range entered by user
        Range = double.empty(1, 0)

        % IxFitted  Logical index of dates in estimation range acutally fitted
        IxFitted = logical.empty(1, 0)

        GroupNames (1, :) string = string.empty(1, 0) % Groups in panel objects

        % IsIdentified  True for structural VAR models, false for reduced-form VAR models
        IsIdentified (1, 1) logical = false
    end


    properties (Dependent)
        % EigenValues  Eigenvalues of VAR transition matrix
        EigenValues

        % AllNames  List of all endogenous, residual, exogenous, conditioning and reporting names in VAR
        AllNames

        YNames
        ENames
        XNames
        INames

        % NumEndogenous  Number of endogenous variables
        NumEndogenous

        % NumResiduals  Number of errors
        NumResiduals

        % NumExogenous  Number of exogenous variables
        NumExogenous

        % NumConditioning  Number of conditioning instruments
        NumConditioning

        % NumGroups  Number of groups in panel VARs
        NumGroups

        % InxFitted  Logical index of dates in estimation range acutally fitted
        InxFitted

        % IsPanel  True if this is a panel model
        IsPanel

        % A_  Transition matrix 
        A_
    end


    properties (Constant)
        PREFIX_ERRORS = 'res_'
    end


    methods
        varargout = access(varargin)
        varargout = assign(varargin)
        varargout = companion(varargin)
        varargout = datarequest(varargin)
        varargout = horzcat(varargin)
        varargout = isempty(varargin)
        varargout = nfitted(varargin)
        varargout = schur(varargin)
        varargout = length(varargin)
    end


    methods (Hidden)
        function value = countVariants(this)
            value = size(this.A, 3);
        end%


        function flag = checkConsistency(this)
            flag = checkConsistency@iris.mixin.GetterSetter(this) ...
                   && checkConsistency@iris.mixin.UserDataContainer(this);
        end%


        varargout = myoutpdata(varargin)
        varargout = myselect(varargin)
        varargout = implementGet(varargin)
        varargout = testCompatible(varargin)
        varargout = vertcat(varargin)
    end


    methods (Access=protected, Hidden)
        varargout = runGroups(varargin)
        varargout = preallocate(varargin)
        varargout = subsalt(varargin)


        function residualNames = printResidualNames(this)
            residualNames = string(this.PREFIX_ERRORS) + this.EndogenousNames;
        end%


        function implementDisp(varargin)
        end%
    end


    methods (Static, Hidden)
        varargout = mytelltime(varargin)
    end


    methods
        function this = BaseVAR(varargin)
            %( Input parser
            persistent pp
            if isempty(pp)
                pp = extend.InputParser('BaseVAR.BaseVAR');
                pp.addRequired('EndogenousNames', @(x) isempty(x) || validate.list(x));
                pp.addParameter('Comment', '', @validate.scalarString);
                pp.addParameter({'ExogenousNames', 'Exogenous'}, string.empty(1, 0), @validate.list);
                pp.addParameter({'GroupNames', 'Groups'}, string.empty(1, 0), @validate.list);
                pp.addParameter("ResidualNames", string.empty(1, 0), @validate.list);
                pp.addParameter('Order', 1, @(x) validate.roundScalar(x, 0, Inf));
                pp.addParameter('Intercept', true, @validate.logicalScalar);
                pp.addUserDataOption( );
                pp.addBaseYearOption( );
            end
            %)

            if isempty(varargin)
                return
            end

            if numel(varargin)==1 && isa(varargin, 'BaseVAR')
                this = varargin{1};
                return
            end

            opt = pp.parse(varargin{:});

            this.EndogenousNames = pp.Results.EndogenousNames;
            this.ResidualNames = string.empty(1, 0);
            this.ExogenousNames = opt.ExogenousNames;
            this.GroupNames = opt.GroupNames;
            this.ResidualNames = string.empty(1, 0);
            this.ResidualNames = opt.ResidualNames;
            this.UserData = opt.UserData;
            this.BaseYear = opt.BaseYear;
            this.Intercept = opt.Intercept;
            this.Order = opt.Order;
        end%
    end


    methods
        varargout = getResidualComponents(varargin);

        function x = get.A_(this)
            numY = size(this.A, 1);
            x = reshape(this.A, numY, numY, this.Order);
        end%


        function x = get.EigenValues(this)
            x = this.EigVal;
        end%


        function names = get.AllNames(this)
            names = [
                this.EndogenousNames, ...
                this.ExogenousNames, ...
                this.ResidualNames, ...
                this.ConditioningNames, ...
            ];
        end%


        function names = get.ResidualNames(this)
            names = this.ResidualNames;
            if isempty(names)
                names = string(this.PREFIX_ERRORS) + this.EndogenousNames;
            end
        end%


        function num = get.NumEndogenous(this)
            num = numel(this.EndogenousNames);
        end%


        function num = get.NumResiduals(this)
            num = this.NumEndogenous;
        end%


        function num = get.NumExogenous(this)
            num = numel(this.ExogenousNames);
        end%


        function num = get.NumConditioning(this)
            num = numel(this.ConditioningNames);
        end%


        function num = get.NumGroups(this)
            num = numel(this.GroupNames);
        end%


        function inx = get.InxFitted(this)
            inx = this.IxFitted;
        end%


        function value = get.IsPanel(this)
            value = ~isempty(this.GroupNames);
        end%


        function newNames = beforeSettingNames(this, newNames, numRequired)
            newNames = reshape(string(newNames), 1, [ ]);
            numNewNames = numel(newNames);
            if numRequired>0 && numNewNames~=numRequired
                exception.error([
                    "BaseVar:InvalidNumNamesAssigned"
                    "Invalid number of names assigned to %sNames in a %s object. "
                    "The number of names required is %g while the number of names assigned is %g. "
                ], class(this), numRequired, numNewNames);
            end
        end%


        function this = set.EndogenousNames(this, newNames)
            newNames = beforeSettingNames(this, newNames, numel(this.EndogenousNames));
            this.EndogenousNames = newNames;
            checkNames(this);
        end%


        function this = set.ResidualNames(this, newNames)
            if isempty(newNames)
                this.ResidualNames = printResidualNames(this);
                return
            end
            newNames = beforeSettingNames(this, newNames, numel(this.EndogenousNames));
            this.ResidualNames = newNames;
            checkNames(this);
        end%


        function this = set.ExogenousNames(this, newNames)
            newNames = beforeSettingNames(this, newNames, numel(this.ExogenousNames));
            this.ExogenousNames = newNames;
            checkNames(this);
        end%


        function this = set.GroupNames(this, newNames)
            if isempty(newNames)
                if size(this.InxFitted, 1)>1 || size(this.K, 2)>1 || size(this.X0, 2)>1 || size(this.J, 2)>this.NumExogenous
                    exception.error([
                        "BaseVAR:CannotEmptyGroups"
                        "Cannot reset GroupNames to empty when coefficient matrices contain "
                        "data for more than one group. "
                    ]);
                end
                this.GroupNames = string.empty(1, 0);
                return
            end
            newNames = beforeSettingNames(this, newNames, numel(this.GroupNames));
            this.GroupNames = newNames;
        end%


        function this = set.ConditioningNames(this, newNames)
            if isempty(newNames)
                this.ConditioningNames = string.empty(1, 0);
                return
            end
            this.ConditioningNames = newNames;
            checkNames(this);
        end%


        function checkNames(this)
            checkValid(this);
            checkPrefix(this);
            checkUnique(this);
        end%


        function checkValid(this)
            allNames = reshape(string(this.AllNames), 1, [ ]);
            inxValid = arrayfun(@isvarname, allNames);
            if ~all(inxValid)
                exception.error([
                    "BaseVAR:InvalidName"
                    "This is not a valid %1 model name: %s "
                ], class(this), allNames(~inxValid));
            end
        end%


        function checkPrefix(this)
            invalidNames = string.empty(1, 0);
            for n = ["Endogenous", "Exogenous", "Conditioning"]
                property = n + "Names";
                inxStartsWithPrefix = startsWith( ...
                    this.(property), this.PREFIX_ERRORS ...
                );
                if any(inxStartsWithPrefix)
                    invalidNames = [invalidNames, this.(property)(inxStartsWithPrefix)];
                end
            end
            if any(inxStartsWithPrefix)
                exception.error([
                    "BaseVAR:checkPrefix"
                    "This %s model name starts with a reserved prefix: %s "
                ], class(this), invalidNames);
            end
        end%


        function checkUnique(this)
            [flag, duplicateNames] = textual.nonunique(this.AllNames);
            if flag
                exception.error([
                    "VAR:MultipleNames"
                    "This name has been assigned more than once in the %s model object: %s "
                ], class(this), string(duplicateNames));
            end
        end%
    end


    methods % Legacy
        %(
        function value = get.YNames(this)
            value = this.EndogenousNames;
        end%


        function value = get.ENames(this)
            value = this.ResidualNames;
        end%


        function value = get.XNames(this)
            value = this.ExogenousNames;
        end%


        function value = get.INames(this)
            value = this.ConditioningNames;
        end%


        function this = set.YNames(this, value)
            this.EndogenousNames = value;
        end%


        function this = set.ENames(this, value)
            this.ResidualNames = value;
        end%


        function this = set.XNames(this, value)
            this.ExogenousNames = value;
        end%


        function this = set.INames(this, value)
            this.ConditioningNames = value;
        end%
        %)
    end


    methods (Access=protected) % Implement CustomDisplay
        %(
        function groups = getPropertyGroups(this)
            x = struct( );
            x.EndogenousNames = this.EndogenousNames;
            x.ExogenousNames = this.ExogenousNames;
            x.NumEndogenous = numel(this.EndogenousNames);
            x.Order = this.Order;
            x.NumVariants = countVariants(this);
            x.ConditioningNames = this.ConditioningNames;
            if this.IsPanel
                x.GroupNames = this.GroupNames;
            end
            x.Comment = string(this.Comment);
            x.UserData = this.UserData;
            groups = matlab.mixin.util.PropertyGroup(x);
        end%


        function displayScalarObject(this)
            groups = getPropertyGroups(this);
            disp(getHeader(this));
            disp(groups.PropertyList);
        end%


        function displayNonScalarObject(this)
            displayScalarObject(this);
        end%


        function header = getHeader(this)
            dimString = matlab.mixin.CustomDisplay.convertDimensionsToString(this);
            className = matlab.mixin.CustomDisplay.getClassNameForHeader(this);
            adjective = string.empty(1, 0);
            if isempty(this)
                adjective(end+1) = "Empty";
            end
            if this.IsPanel
                adjective(end+1) = "Panel";
            end
            if isempty(adjective)
                adjective = " ";
            else
                adjective = " " + join(adjective, " ") + " ";
            end
            header = "  " + string(dimString) + adjective + string(className) + string(newline( ));
        end%
        %)
    end % methods


    methods % Implement iris.mixin.DatabankPipe
        %(
        function appendables = nameAppendables(this)
            appendables = [
                this.EndogenousNames, ...
                this.ExogenousNames, ...
                this.ResidualNames, ...
            ];
        end%


        function [minSh, maxSh] = getActualMinMaxShifts(this)
            minSh = -this.Order;
            maxSh = 0;
        end%
        %)
    end
end
