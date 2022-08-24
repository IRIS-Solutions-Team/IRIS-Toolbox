function flag = chkQty(this, variantsRequested, varargin)

if isequal(variantsRequested, Inf)
    variantsRequested = ':';
end

for i = 1 : length(varargin)
    switch varargin{i}
        case 'log'
            flag = checkZeroLog(this, variantsRequested);
        case 'parameters'
            % Throw warning if some parameters are not assigned.
            [~, list] = isnan(this, 'parameters', variantsRequested);
            flag = isempty(list);
            if ~flag
                throw( exception.Base('Model:PARAMETER_NOT_ASSIGNED', 'warning'), ...
                       list{:} );
            end
        case 'parameters:dynamic'
            % Throw warning if some parameters are not assigned but occur
            % in dynamic equations.
            levels = real( this.Variant.Values(:, :, variantsRequested) );
            ixp = this.Quantity.Type==4;
            ixNeeded = across(this.Incidence.Dynamic, 'Eqtn');
            ixNeeded = any(ixNeeded, 2).';
            ixNan = any(isnan(levels), 3);
            ixRpt = ixp & ixNan & ixNeeded;
            flag = ~any(ixRpt);
            if ~flag
                throw( exception.Base('Model:PARAMETER_NOT_ASSIGNED', 'warning'), ...
                       this.Quantity.Name{ixRpt} );
            end
        case 'parameters:steady'
            % Throw warning if some parameters are not assigned but occur
            % in steady equations.
            levels = real( this.Variant.Values(:, :, variantsRequested) );
            ixp = this.Quantity.Type==4;
            ixNeeded = across(this.Incidence.Steady, 'Eqtn');
            ixNeeded = any(ixNeeded, 2).'; 
            ixNan = any(isnan(levels), 3);
            ixRpt = ixp & ixNan & ixNeeded;
            flag = ~any(ixRpt);
            if ~flag
                throw( exception.Base('Model:PARAMETER_NOT_ASSIGNED', 'warning'), ...
                       this.Quantity.Name{ixRpt} );
            end
        case 'sstate'
            % Throw warning if some steady states are not assigned.
            [~, list] = isnan(this, 'sstate', variantsRequested);
            flag = isempty(list);
            if ~flag
                throw( exception.Base('Model:STEADY_NOT_AVAILABLE', 'warning'), ...
                       list{:} );
            end
    end
end

end
