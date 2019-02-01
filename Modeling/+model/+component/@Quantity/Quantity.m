classdef (CaseInsensitiveProperties=true) Quantity < model.component.Insertable
    properties
        Name = cell.empty(1, 0)             % Quantity names
        Type = int8.empty(1, 0)             % Quantity type
        Label = cell.empty(1, 0)            % Description
        Alias = cell.empty(1, 0)            % LaTeX representation of quantity name or description
        IxLog = logical.empty(1, 0)         % True for log variables
        IxLagrange = logical.empty(1, 0)    % True for Lagrange multipliers in optimal policy models
        IxObserved = logical.empty(1, 0)    % True for transition variables marked as observed and forced into the backward looking vector
        Bounds = double.empty(4, 0)         % Lower and upper bounds on level and growth
    end


    properties (Hidden)
        OriginalNames = cell.empty(1, 0)     % Original names from source model file
    end
    
    
    properties (Constant, Hidden)
        TYPE_ORDER = int8([1, 2, 31, 32, 4, 5])
        DEFAULT_BOUNDS = [-Inf; Inf; -Inf; Inf]
    end


    properties (Dependent)
        InxOfLog
        NumOfQuantities
        LabelOrName
        Label4ShockContributions
    end
    
    
    methods
        varargout = changeLogStatus(varargin)
        varargout = checkConsistency(varargin)
        varargout = createTemplateDbase(varargin)
        varargout = getCorrNames(varargin)
        varargout = getStdNames(varargin)
        varargout = implementGet(varargin)
        varargout = isCompatible(varargin)
        varargout = isName(varargin)
        varargout = length(varargin)
        varargout = lookup(varargin)
        varargout = pattern4postparse(varargin)
        varargout = remove(varargin)
        varargout = rename(varargin)
        varargout = saveObject(varargin)
        varargout = size(varargin);
        varargout = userSelection2Index(varargin)


        function this = resetNames(this)
            this.Name = this.OriginalNames;
        end%


        function value = get.InxOfLog(this)
            value = this.IxLog;
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
            numOfE = nnz(inxOfE);
            contributions = [ this.Name(inxOfE), ...
                              {'Init+Const+Trends', 'Nonlinear'} ];
            posOfYX = find(inxOfYX);
            inxOfLog = this.InxOfLog;
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
            flag = isempty(this.Name);
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
    end

    
    methods (Static)
        varargout = loadObject(varargin)
    end
end
