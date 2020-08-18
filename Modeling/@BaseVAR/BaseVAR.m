% BaseVAR  Superclass for VAR based model objects
%
% Backend IRIS class
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

classdef (CaseInsensitiveProperties=true) ...
    BaseVAR ...
    < shared.UserDataContainer ...
    & shared.CommentContainer ...
    & shared.GetterSetter

    properties
        % Tolerance  Tolerance level object
        Tolerance = shared.Tolerance( )

        % YNames  Names of endogenous variables
        YNames = cell.empty(1, 0) 

        % ENames  Names of forecast errors
        ENames = @auto

        % XNames  Names of exogenous variables
        XNames = cell.empty(1, 0)
        
        % INames  Names of conditioning variables
        INames = cell.empty(1, 0) 

        % IEqtn  Expressions for conditioning variables
        IEqtn = cell.empty(1, 0) 

        Intercept (1, 1) logical = true

        Order (1, 1) double = 1

        % A  Transition matrices with higher orders concatenated horizontally
        A = double.empty(0) 

        % K  Vector of intercepts (constant terms)
        K = double.empty(0, 1)

        T = double.empty(0) % Schur quasitriangular matrix
        U = double.empty(0) % Schur unitary matrix

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
        
        GroupNames = cell.empty(1, 0) % Groups in panel objects

        Reporting = rpteq.empty(1, 0) % Reporting equations
    end
    

    properties (Dependent)
        % EigenValues  Eigenvalues of VAR transition matrix
        EigenValues
        
        % AllNames  List of all names in VAR: endogenous, errors, exogenous, conditioning, reporting
        AllNames

        % NamesEndogenous  Names of endogenous variables
        NamesEndogenous

        % NamesErrors  Names of errors
        NamesErrors

        % NamesExogenous  Names of exogenous variables
        NamesExogenous

        % NamesConditioning  Names of conditioning instruments
        NamesConditioning

        % NamesGroups  Names of groups in panel VARs
        NamesGroups

        NamesReporting

        % NumEndogenous  Number of endogenous variables
        NumEndogenous
        
        % NumErrors  Number of errors
        NumErrors

        % NumExogenous  Number of exogenous variables
        NumExogenous

        % NumConditioning  Number of conditioning instruments
        NumConditioning

        % NumGroups  Number of groups in panel VARs
        NumGroups

        NumReporting
        
        % IndexFitted  Logical index of dates in estimation range acutally fitted
        IndexFitted
    end


    properties (Constant)
        PREFIX_ERRORS = 'res_'
    end

    
    methods
        varargout = assign(varargin)
        varargout = datarequest(varargin)
        varargout = horzcat(varargin)
        varargout = isempty(varargin)
        varargout = ispanel(varargin)
        varargout = nfitted(varargin)
        varargout = schur(varargin)
        varargout = length(varargin)
    end
    
    
    methods (Hidden)
        function value = countVariants(this)
            value = size(this.A, 3);
        end%


        function flag = checkConsistency(this)
            flag = checkConsistency@shared.GetterSetter(this) ...
                   && checkConsistency@shared.UserDataContainer(this);
        end%

        
        function disp(varargin)
            implementDisp(varargin{:});
            textual.looseLine( );
        end%


        function names = nameAppendables(this)
            names = [this.NamesEndogenous, this.NamesExogenous, this.NamesErrors];
        end%


        varargout = myoutpdata(varargin)
        varargout = myselect(varargin)
        varargout = implementGet(varargin)
        varargout = testCompatible(varargin)        
        varargout = vertcat(varargin)
    end
    
    
    
    
    methods (Access=protected, Hidden)
        implementDisp(varargin)
        varargout = mygroupmethod(varargin)
        varargout = mygroupnames(varargin)
        varargout = myny(varargin)
        varargout = myprealloc(varargin)
        varargout = subsalt(varargin)
        varargout = specdisp(varargin)
    end
    
    
    
    
    methods (Static, Hidden)
        varargout = loadobj(varargin)
        varargout = mytelltime(varargin)
    end
    
    
    
    
    methods
        function this = BaseVAR(varargin)
            persistent pp
            if isempty(pp)
                pp = extend.InputParser('BaseVAR.BaseVAR');
                pp.addRequired('EndogenousNames', @validate.list);
                pp.addParameter('Comment', '', @validate.scalarString);
                pp.addParameter({'ExogenousNames', 'Exogenous'}, cell.empty(1, 0), @(x) ischar(x) || iscellstr(x) || isa(x, 'string'));
                pp.addParameter({'GroupNames', 'Groups'}, cell.empty(1, 0), @(x) ischar(x) || iscellstr(x) || isa(x, 'string'));
                pp.addParameter('Reporting', cell.empty(1, 0), @(x) ischar(x) || iscellstr(x) || isa(x, 'string'));
                pp.addParameter('Order', 1, @(x) validate.roundScalar(x, 0, Inf));
                pp.addParameter('Intercept', true, @validate.logicalScalar);
                pp.addUserDataOption( );
                pp.addBaseYearOption( );
            end

            if isempty(varargin)
                return
            end
            
            if length(varargin)==1 && isa(varargin, 'BaseVAR')
                this = varargin{1};
                return
            end
            
            pp.parse(varargin{:});

            % Create Reporting before all other names so that AllNames
            % include reporting names when checking for uniqueness
            reportingFiles = pp.Results.Reporting;
            if ~iscellstr(reportingFiles)
                reportingFiles = cellstr(reportingFiles);
            end
            if ~isempty(reportingFiles)
                for i = 1 : numel(reportingFiles)
                    this.Reporting(1, end+1) = rpteq(reportingFiles{i});
                end
            end

            opt = pp.Options;
            this.NamesEndogenous = pp.Results.EndogenousNames;
            this.NamesErrors = @auto;
            this.NamesExogenous = opt.ExogenousNames;
            this.GroupNames = opt.GroupNames;
            this.UserData = opt.UserData;
            this.BaseYear = opt.BaseYear;

            this.Intercept = opt.Intercept;
            this.Order = opt.Order;
        end%
    end


    methods
        function x = get.EigenValues(this)
            x = this.EigVal;
        end%


        function names = get.AllNames(this)
            names = [ this.NamesEndogenous, ...
                      this.NamesExogenous, ...
                      this.NamesErrors, ...
                      this.NamesConditioning, ...
                      this.NamesReporting         ];
        end%


        function names = get.NamesEndogenous(this)
            names = this.YNames;
            if ~isempty(names)
                names = names(:)';
            else
                names = cell.empty(1, 0);
            end
        end%


        function names = get.NamesErrors(this)
            names = this.ENames;
            if isequal(names, @auto)
                names = strcat(this.PREFIX_ERRORS, this.NamesEndogenous);
            elseif ~isempty(names)
                names = names(:)';
            else
                names = cell.empty(1, 0);
            end
        end%


        function names = get.NamesExogenous(this)
            names = this.XNames;
            if ~isempty(names)
                names = names(:)';
            else
                names = cell.empty(1, 0);
            end
        end%


        function names = get.NamesConditioning(this)
            names = this.INames;
            if ~isempty(names)
                names = names(:)';
            else
                names = cell.empty(1, 0);
            end
        end%


        function names = get.NamesGroups(this)
            names = this.GroupNames;
            if ~isempty(names)
                names = names(:)';
            else
                names = cell.empty(1, 0);
            end
        end%


        function names = get.NamesReporting(this)
            if isempty(this.Reporting)
                names = cell.empty(1, 0);
                return
            end
            names = [this.Reporting(:).NamesOfLhs];
        end%


        function num = get.NumEndogenous(this)
            num = numel(this.YNames);
        end%


        function num = get.NumErrors(this)
            num = this.NumEndogenous;
        end%


        function num = get.NumExogenous(this)
            num = numel(this.XNames);
        end%


        function num = get.NumConditioning(this)
            num = numel(this.INames);
        end%


        function num = get.NumGroups(this)
            num = numel(this.GroupNames);
        end%


        function index = get.IndexFitted(this)
            index = this.IxFitted;
        end%


        function this = set.NamesEndogenous(this, newNames)
            numEndogenous = this.NumEndogenous;
            if ischar(newNames)
                newNames = regexp(newNames, '\w+', 'match');
            elseif isa(newNames, 'string')
                newNames = cellstr(newNames);
            end
            numNewNames = numel(newNames);
            assert( ...
                numEndogenous==0 || numNewNames==numEndogenous, ...
                'BaseVAR:set:NamesEndogenous', ...
                'Illegal number of names for endogenous variables.' ...
            );
            newNames = newNames(:)';
            this.YNames = newNames;
            checkNames(this);
        end


        function this = set.NamesErrors(this, newNames)
            if ischar(newNames)
                newNames = regexp(newNames, '\w+', 'match');
            elseif isa(newNames, 'string')
                newNames = cellstr(newNames);
            end
            assert( ...
                isequal(newNames, @auto) ...
                    || numel(newNames)==this.NumNamesEndogenous, ...
                'BaseVAR:set:NamesErrors', ...
                'Illegal number of names for error terms.' ...
            );
            if ~isequal(newNames, @auto)
                newNames = newNames(:)';
            end
            this.ENames = newNames;
            checkNames(this);
        end

            
        function this = set.NamesExogenous(this, newNames)
            if isempty(newNames)
                newNames = cell.empty(1, 0);
            end
            numExogenous = this.NumExogenous;
            if ischar(newNames)
                newNames = regexp(newNames, '\w+', 'match');
            elseif isa(newNames, 'string')
                newNames = cellstr(newNames);
            end
            numNewNames = numel(newNames);
            assert( ...
                numExogenous==0 || numNewNames==numExogenous, ...
                'BaseVAR:set:NamesExogenous', ...
                'Illegal number of names for exogenous variables.' ...
            );
            newNames = newNames(:)';
            this.XNames = newNames;
            checkNames(this);
        end


        function this = set.NamesConditioning(this, newNames)
            if isempty(newNames)
                this.INames = cell.empty(1, 0);
                return
            end
            newNames = newNames(:)';
            this.INames = newNames;
            checkNames(this);
        end


        function checkNames(this)
            checkValid(this);
            checkPrefix(this);
            checkUnique(this);
        end


        function checkValid(this)
            allNames = this.AllNames;
            indexValid = true(size(allNames));
            for i = 1 : numel(allNames)
                indexValid = isvarname(allNames{i});
            end
            assert( ...
                all(indexValid), ...
                'BaseVAR:checkValid', ...
                'This is not a legal name for variables or error terms: %s ', ...
                allNames{~indexValid} ...
            );
        end


        function checkPrefix(this)
            lenPrefix = length(this.PREFIX_ERRORS);
            % Check names of endogenous variables
            namesEndogenous = this.NamesEndogenous;
            indexEndogenousStartsWithPrefix = strncmp( ...
                namesEndogenous, this.PREFIX_ERRORS, lenPrefix ...
            );
            assert( ...
                ~any(indexEndogenousStartsWithPrefix), ...
                'BaseVAR:checkPrefix', ...
                'This endogenous variable name starts with a reserved prefix: %s ', ...
                namesEndogenous(indexEndogenousStartsWithPrefix) ...
            );
            % Check names of exogenous variables
            namesExogenous = this.NamesExogenous;
            indexExogenousStartsWithPrefix = strncmp( ...
                namesExogenous, this.PREFIX_ERRORS, lenPrefix ...
            );
            assert( ...
                ~any(indexExogenousStartsWithPrefix), ...
                'BaseVAR:checkPrefix', ...
                'This exogenous variable name starts with a reserved prefix: %s ', ...
                namesExogenous(indexExogenousStartsWithPrefix) ...
            );
            % Check names of conditioning variables
            namesConditioning = this.NamesConditioning;
            indexConditioningStartsWithPrefix = strncmp( ...
                namesConditioning, this.PREFIX_ERRORS, lenPrefix ...
            );
            assert( ...
                ~any(indexConditioningStartsWithPrefix), ...
                'BaseVAR:checkPrefix', ...
                'This conditioning variable name starts with a reserved prefix: %s ', ...
                namesConditioning(indexConditioningStartsWithPrefix) ...
            );
        end


        function checkUnique(this)
            [flag, duplicateNames] = textual.nonunique(this.AllNames);
            if flag
                throw( exception.Base('VAR:NonuniqueName', 'error'), ...
                       duplicateNames{:} );
            end
        end%
    end
end
