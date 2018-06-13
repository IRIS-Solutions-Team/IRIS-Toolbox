function flag = chkQty(this, variantsRequested, varargin)
% chkQty  Check quantities for missing or log-zero values.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

TYPE = @int8;
STEADY_TOLERANCE = this.Tolerance.Steady;

%--------------------------------------------------------------------------

if isequal(variantsRequested, Inf)
    variantsRequested = ':';
end

for i = 1 : length(varargin)
    switch varargin{i}
        case 'log'
            lvl = this.Variant.Values(:, :, variantsRequested);
            ixLogZero = this.Quantity.IxLog & any(abs(lvl)<=STEADY_TOLERANCE, 3);
            flag = ~any(ixLogZero);
            list = this.Quantity.Name(ixLogZero);
            if ~flag
                throw( ...
                    exception.Base('Model:LOG_VARIABLE_ZERO_STEADY', 'warning'), ...
                    list{:} ...
                    );
            end
        case 'parameters'
            % Throw warning if some parameters are not assigned.
            [~, list] = isnan(this, 'parameters', variantsRequested);
            flag = isempty(list);
            if ~flag
                throw( ...
                    exception.Base('Model:PARAMETER_NOT_ASSIGNED', 'warning'), ...
                    list{:} ...
                    );
            end
        case 'parameters:dynamic'
            % Throw warning if some parameters are not assigned but occur
            % in dynamic equations.
            lvl = real( this.Variant.Values(:, :, variantsRequested) );
            ixp = this.Quantity.Type==TYPE(4);
            ixNeeded = across(this.Incidence.Dynamic, 'Eqtn');
            ixNeeded = any(ixNeeded, 2).';
            ixNan = any(isnan(lvl), 3);
            ixRpt = ixp & ixNan & ixNeeded;
            flag = ~any(ixRpt);
            if ~flag
                throw( ...
                    exception.Base('Model:PARAMETER_NOT_ASSIGNED', 'warning'), ...
                    this.Quantity.Name{ixRpt} ...
                    );
            end
        case 'parameters:steady'
            % Throw warning if some parameters are not assigned but occur
            % in steady equations.
            lvl = real( this.Variant.Values(:, :, variantsRequested) );
            ixp = this.Quantity.Type==TYPE(4);
            ixNeeded = across(this.Incidence.Steady, 'Eqtn');
            ixNeeded = any(ixNeeded, 2).'; 
            ixNan = any(isnan(lvl), 3);
            ixRpt = ixp & ixNan & ixNeeded;
            flag = ~any(ixRpt);
            if ~flag
                throw( ...
                    exception.Base('Model:PARAMETER_NOT_ASSIGNED', 'warning'), ...
                    this.Quantity.Name{ixRpt} ...
                    );
            end
        case 'sstate'
            % Throw warning if some steady states are not assigned.
            [~, list] = isnan(this, 'sstate', variantsRequested);
            flag = isempty(list);
            if ~flag
                throw( ...
                    exception.Base('Model:STEADY_NOT_AVAILABLE', 'warning'), ...
                    list{:} ...
                    );
            end
    end
end

end
