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
    end
    
    
    methods
        varargout = changeLogStatus(varargin)
        varargout = checkConsistency(varargin)
        varargout = createTemplateDbase(varargin)
        varargout = getCorrNames(varargin)
        varargout = getLabelOrName(varargin)
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
    end


    methods
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
