classdef (CaseInsensitiveProperties=true) ...
    Quantity ...
    < model.component.Insertable

    properties
        % Name  Names of quantities
        Name = cell.empty(1, 0)

        % Type  Types of quantities
        Type = int8.empty(1, 0)   

        % Label  Description of quantities
        Label = cell.empty(1, 0)         

        % Alias  Alias strings for quantities
        Alias = cell.empty(1, 0)            

        % InxLog  True for variabls declared as log-variables
        IxLog = logical.empty(1, 0)

        % IxLagrange  True for Lagrange multipliers in optimal policy model
        IxLagrange = logical.empty(1, 0)          

        % IxObserved  True for transition variables marked as observed and forced into the backward looking vector
        IxObserved = logical.empty(1, 0)          

        % Bounds  Lower and upper bounds on level and growth
        Bounds = double.empty(4, 0)               
    end


    properties (Hidden)
        % OriginalName  Original names from source model file
        OriginalNames = cell.empty(1, 0)          

        % GroupNames  Names of quantity groups
        GroupNames = cell.empty(1, 0)        

        % GroupMembership  Membership of quantities in groups
        GroupMembership = logical.empty(0, 0)
    end
    
    
    properties (Constant, Hidden)
        TYPE_ORDER = int8([1, 2, 31, 32, 4, 5])
        DEFAULT_BOUNDS = [-Inf; Inf; -Inf; Inf]
        RESERVED_NAME_TTREND = 'ttrend'
        RESERVED_NAME_LINEAR = 'linear'
        STD_PREFIX = 'std_'
        CORR_PREFIX = 'corr_'
        LOG_PREFIX = 'log_'
        FLOOR_PREFIX = 'floor_'
    end


    properties (Dependent)
        InxLog
        NumOfQuantities
        LabelOrName
        Label4ShockContributions
    end
    
    
    methods
        varargout = changeLogStatus(varargin)
        varargout = checkConsistency(varargin)
        varargout = createTemplateDbase(varargin)
        varargout = enforceLogStatus(varargin)
        varargout = getCorrNames(varargin)
        varargout = getStdNames(varargin)
        varargout = implementGet(varargin)
        varargout = initializeLogStatus(varargin)
        varargout = testCompatible(varargin)
        varargout = isName(varargin)

        function n = length(this)
            n = length(this.Name);
        end%

        function n = numel(this)
            n = numel(this.Name);
        end%

        varargout = lookup(varargin)
        varargout = pattern4postparse(varargin)
        varargout = printVector(varargin)
        varargout = remove(varargin)
        varargout = rename(varargin)
        varargout = saveObject(varargin)
        varargout = size(varargin);
        varargout = userSelection2Index(varargin)


        function this = resetNames(this)
            this.Name = this.OriginalNames;
        end%


        function value = get.InxLog(this)
            value = this.IxLog;
        end%


        function this = set.InxLog(this, value)
            this.IxLog = value;
        end%


        function n = get.NumOfQuantities(this)
            n = numel(this.Name);
        end%


        function value = get.LabelOrName(this)
            value = this.Label;
            ixEmpty = cellfun('isempty', value);
            value(ixEmpty) = this.Name(ixEmpty);
        end%


        function value = get.Label4ShockContributions(this)
            TYPE = @int8;
            value = this.LabelOrName;
            inxOfYX = getIndexByType(this, TYPE(1), TYPE(2));
            inxOfE = getIndexByType(this, TYPE(31), TYPE(32));
            numE = nnz(inxOfE);
            contributions = [ this.Name(inxOfE), ...
                              {'Init+Const+Trends', 'Nonlinear'} ];
            posOfYX = find(inxOfYX);
            inxOfLog = this.InxLog;
            for pos = posOfYX
                name = this.Name(pos);
                if inxOfLog(pos)
                    sign = '<-(*)';
                else
                    sign = '<-(+)';
                end
                value{pos} = strcat(name, sign, contributions);
            end
        end%
    end


    methods
        function flag = isempty(this)
            flag = numel(this)==0 || isempty(this.Name);
        end%


        function index = getIndexByType(this, varargin)
            index = false(size(this.Name));
            for i = 1 : numel(varargin)
                index = index | this.Type==varargin{i};
            end
        end%


        function list = getNamesByType(this, varargin)
            index = getIndexByType(this, varargin{:});
            list = this.Name(index);
        end%


        function pos = getPosTimeTrend(this)
            pos = find(string(this.Name)==string(this.RESERVED_NAME_TTREND));
        end%
    end

    
    methods (Static)
        varargout = loadObject(varargin)


        function this = fromNames(names)
            names = cellstr(names);
            this = model.component.Quantity( );
            numNames = numel(names);
            this.Name = cell(1, numNames);
            this.Name(:) = names;
            this.Type = zeros(1, numNames, 'int8');
            this.Label = repmat({''}, 1, numNames);
            this.Alias = repmat({''}, 1, numNames);
            this.IxLog = false(1, numNames);
            this.IxLagrange = false(1, numNames);
            this.IxObserved = false(1, numNames);
            this.Bounds = repmat(this.DEFAULT_BOUNDS, 1, numNames);
            this.OriginalNames = this.Name;
        end%
    end
end

