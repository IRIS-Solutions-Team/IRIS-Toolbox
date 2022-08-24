classdef (CaseInsensitiveProperties=true) ...
    Quantity ...
    < model.Insertable

    properties
        % Properties that are not Hidden are Insertable

        % Name  Names of quantities
        Name = cell.empty(1, 0)

        % Type  Types of quantities
        Type = int8.empty(1, 0)

        % Label  Description of quantities
        Label = cell.empty(1, 0)

        % Alias  Alias strings for quantities
        Alias = cell.empty(1, 0)

        % Attributes  Quantity attributes
        Attributes = cell.empty(1, 0)

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
        % Hidden properties are not insertable

        % OriginalName  Original names from source model file
        OriginalNames = string.empty(1, 0)

        % GroupNames  Names of quantity groups
        GroupNames = cell.empty(1, 0)

        % GroupMembership  Membership of quantities in groups
        GroupMembership = logical.empty(0, 0)
    end


    properties (Transient)
        % Transient properties are not insertable

        % LookupTable  Lookup table for base names
        LookupTable = struct()
    end


    properties (Constant, Hidden)
        TYPE_ORDER = [1, 2, 31, 32, 4, 5]
        DEFAULT_BOUNDS = [-Inf; Inf; -Inf; Inf]
        RESERVED_NAME_TTREND = 'ttrend'
        RESERVED_NAME_LINEAR = 'linear'

        STD_PREFIX = 'std_'
        CORR_PREFIX = 'corr_'
        LOG_PREFIX = 'log_'
        FLOOR_PREFIX = 'floor_'
        COSTD_PREFIX = 'costd_'
        SLACK_PREFIX = 'slack_'

        RESERVED_PREFIXES = [
            string(model.Quantity.STD_PREFIX) 
            string(model.Quantity.CORR_PREFIX)
            string(model.Quantity.LOG_PREFIX)
            string(model.Quantity.COSTD_PREFIX)
            string(model.Quantity.SLACK_PREFIX)
        ]
    end


    properties (Dependent)
        InxLog
        InxObserved
        NumQuantities
    end


    methods
        % Bounds
        varargout = getBounds(varargin)
        varargout = resetBounds(varargin)
        varargout = setBounds(varargin)

        varargout = createLookupTable(varargin)
        varargout = changeLogStatus(varargin)
        varargout = checkConsistency(varargin)
        varargout = createTemplateDbase(varargin)
        varargout = enforceLogStatus(varargin)
        varargout = getCorrNames(varargin)
        varargout = getStdNames(varargin)

        function flag = hasLogVariables(this)
            flag = any(this.InxLog);
        end%

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
        varargout = lookupNames(varargin)

        varargout = byAttributes(varargin)

        varargout = pattern4postparse(varargin)

        varargout = populateTransient(varargin)
        varargout = printVector(varargin)
        varargout = remove(varargin)
        varargout = rename(varargin)
        varargout = saveObject(varargin)
        varargout = seal(varargin)
        varargout = size(varargin)
        varargout = userSelection2Index(varargin)
        varargout = userEquationsFromParsedEquations(varargin)
        varargout = validateNames(varargin)


        function this = resetNames(this)
            this.Name = this.OriginalNames;
        end%


        function value = get.InxLog(this)
            value = this.IxLog;
        end%


        function value = get.InxObserved(this)
            value = this.IxObserved;
        end%


        function this = set.InxLog(this, value)
            this.IxLog = value;
        end%


        function n = get.NumQuantities(this)
            n = numel(this.Name);
        end%


        function numQuantities = countQuantities(this)
            numQuantities = numel(this.Name);
        end%


        function labels = getLabelsOrNames(this, inx)
            labels = string(this.Label);
            names = string(this.Name);
            if nargin>=2
                labels = labels(inx);
                names = names(inx);
            end
            inxEmpty = labels=="";
            labels(inxEmpty) = names(inxEmpty);
        end%


        function value = getLabelsForShockContributions(this)
            labels = getLabelsOrNames(this);
            names = this.Name;

            inxE = getIndexByType(this, 31, 32);
            contributions = [string(this.Name(inxE)), "Init+Const+Trends", "Nonlinear"];

            inxYX = getIndexByType(this, 1, 2);
            inxLog = this.InxLog;
            value = cell(size(labels));
            for pos = 1 : numel(labels)
                if inxYX(pos)
                    name = string(names(pos));
                    if inxLog(pos)
                        sign = "<-(*)";
                    else
                        sign = "<-(+)";
                    end
                    value{pos} = name + sign + contributions;
                else
                    value{pos} = labels(pos);
                end
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


        function pos = locateTrendLine(this, names)
            if isequaln(names, NaN) || isequal(names, Inf)
                names = this.Name;
            end
            pos = find(string(names)==string(this.RESERVED_NAME_TTREND));
        end%
    end


    methods (Static)
        varargout = loadObject(varargin)


        function this = fromNames(names)
            %(
            names = cellstr(names);
            this = model.Quantity();
            numNames = numel(names);
            this.Name = cell(1, numNames);
            this.Name(:) = names;
            this.Type = repmat(int8(0), 1, numNames);
            this.Label = repmat({''}, 1, numNames);
            this.Alias = repmat({''}, 1, numNames);
            this.Attributes = repmat({string.empty(1, 0)}, 1, numNames);
            this.IxLog = false(1, numNames);
            this.IxLagrange = false(1, numNames);
            this.IxObserved = false(1, numNames);
            this.Bounds = repmat(this.DEFAULT_BOUNDS, 1, numNames);
            this.OriginalNames = this.Name;
            %)
        end%


        function std = printStd(shockName)
            std = string(model.Quantity.STD_PREFIX) + string(shockName);
        end%


        function corr = printCorr(shockName1, shockName2)
            corr = string(model.Quantity.CORR_PREFIX) + string(shockName1) + "__" + string(shockName2);
        end%


        function log = printLog(variableName)
            log = string(model.Quantity.LOG_PREFIX) + string(variableName);
        end%
    end
end

