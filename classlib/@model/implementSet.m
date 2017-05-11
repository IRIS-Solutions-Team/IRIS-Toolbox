function [this, isValidRequest, isValidValue] = implementSet(this, query, value, varargin)
% implementSet  Implement set method for model objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

[this, isValidRequest, isValidValue] = ...
    implementSet@shared.UserDataContainer(this, query, value, varargin{:});
if isValidRequest
    return
end

[this.Quantity, isValidRequest, isValidValue] = ...
    implementSet(this.Quantity, query, value, varargin{:});
if isValidRequest
    return
end

[this.Equation, isValidRequest, isValidValue] = ...
    implementSet(this.Equation, query, value, varargin{:});
if isValidRequest
    return
end

[this.Behavior, isValidRequest, isValidValue] = ...
    implementSet(this.Behavior, query, value, varargin{:});
if isValidRequest
    return
end

isValidRequest = true;
isValidValue = true;

switch lower(query)
    case {'stdvec', 'vecstd'}
        ne = length(this.Vector.Solution{3});
        nAlt = length(this.Variant);
        if isnumeric(value) && ...
                (numel(value)==ne || numel(value)==ne*nAlt)
            if numel(value)==ne
                value = value(:).';
                value = repmat(value, 1, nAlt);
            elseif size(value, 3)==1
                value = permute(value, [3, 1, 2]);
            end
            this.Variant = model.Variant.assignStdCorr( ...
                this.Variant, 1:ne, ':', value, ...
                this.Quantity.IxStdCorrAllowed ...
                );
        else
            isValidValue = false;
        end

        
        
        
    case 'userdata'
        this = userdata(this, value);
        



    case 'epsilon'
        if isnumericscalar(value) && value>0
            this.Tolerance.DiffStep = value;
        else
            isValidValue = false;
        end
        



    case {'islinear', 'linear'}
        if islogicalscalar(value)
            this.IsLinear = value;
        else
            isValidValue = false;
        end




    case 'rlabel'
        if iscellstr(value) ...
                && length(value)==length(this.Reporting.Label)
            this.Reporting.Label = value;
        else
            isValidValue = false;
        end
        
    otherwise
        isValidRequest = false;
end

end
