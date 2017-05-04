classdef Quantity < model.Insertable
    properties
        Name = cell(1, 0) % Quantity names.
        Type = repmat(model.Quantity.TYPE(0), 1, 0) % Quantity type.
        Label = cell(1, 0) % Description.
        Alias = cell(1, 0) % LaTeX representation of quantity name or description.
        IxLog = false(1, 0) % True for log variables.
        IxLagrange = false(1, 0) % True for Lagrange multipliers in optimal policy models.
        Bounds = zeros(4, 0) % Lower and upper bounds on level and growth.
    end




    properties (Hidden) % Hidden are non-insertable properties.
        IxStdCorrAllowed % Index of elements in StdCorr that are allowed nonzero.
    end
    
    
    
    
    properties (Constant, Hidden)
        TYPE_ORDER = model.Quantity.TYPE([1, 2, 31, 32, 4, 5])
        DEFAULT_BOUNDS = [-Inf; Inf; -Inf; Inf]
    end
    
    
    
    
    methods
        varargout = chgLogStatus(varargin)
        varargout = chkConsistency(varargin)
        varargout = createTemplateDbase(varargin)
        varargout = getCorrName(varargin)
        varargout = getLabelOrName(varargin)
        varargout = getStdName(varargin)
        varargout = implementGet(varargin)
        varargout = isCompatible(varargin)
        varargout = isName(varargin)
        varargout = length(varargin)
        varargout = lookup(varargin)
        varargout = pattern4postparse(varargin)
        varargout = remove(varargin)
        varargout = saveObject(varargin)
        varargout = size(varargin);
        varargout = userSelection2Index(varargin)




        function this = build(this)
            TYPE = model.Quantity.TYPE;

            % Build index of StdCorr elements that can be nonzero.
            ixe = this.Type==TYPE(31) | this.Type==TYPE(32);
            ne = sum(ixe);
            temp = this.Type(ixe);
            ix31 = temp==model.Quantity.TYPE(31);
            ixCorrAllowed = true(length(temp));
            ixCorrAllowed(ix31, ~ix31) = false;
            ixCorrAllowed(~ix31, ix31) = false;
            ixTril = tril(ones(ne), -1)==1;
            this.IxStdCorrAllowed = [true(1, ne), ixCorrAllowed(ixTril).'];
        end
    end

    
    
    
    
    methods (Static)
        varargout = loadObject(varargin)
    end
end
