%{
% 
% # `reset` ^^(Model)^^
% 
% {== Reset specific values within model object ==}
% 
% 
% ## Syntax
% 
%     model = reset(model)
%     model = reset(model, request)
% 
% 
% ## Input Arguments
% 
% __`model`__ [ Model ] 
% > 
% > Model object in which the requested type(s) of values
% > will be reset.
% > 
% 
% __`request`__ [ `"corr"` | `"plainparameters"` | `"parameters"` | `"steady"` | `"std"` | `"stdcorr"` ] 
% > 
% > Type(s) of values that will be reset; if omitted, everything
% > will be reset.
% > 
% 
% ## Output Arguments
% 
% __`model`__ [ Model ] 
% > 
% > Model object with the requested values reset.
% > 
% 
% ## Description
% 
% * `"corr"` - Reset all cross-correlation coefficients to `0`.
% 
% * `"plainParameters"` - Reset all plain parameters (not including `std_` or `corr_`) to `NaN`.
% 
% * `"parameters"` - Reset all parameters to `NaN`.
% 
% * `"steady"` - Reset all steady state values to `NaN`.
% 
% * `"std"` - Reset all std deviations (`std_`) to `1` (in linear models) or `log(1.01)` (in non-linear models).
% 
% * `"stdCorr"` - Equivalent to `"Std"` and `"Corr"`.
% 
% 
% ## Examples
% 
% 
%}
% --8<--


% Type `web Model/reset.md` for help on this function.
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function this = reset(this, varargin)

inxY = this.Quantity.Type==1;
inxX = this.Quantity.Type==2;
inxE = this.Quantity.Type==31 | this.Quantity.Type==32;
inxP = this.Quantity.Type==4;
inxG = this.Quantity.Type==5;
numE = nnz(inxE);

if this.LinearStatus
    defaultStd = this.DEFAULT_STD_LINEAR;
else
    defaultStd = this.DEFAULT_STD_NONLINEAR;
end

if isempty(varargin)
    resetSteady( );
    resetPlainParameters( );
    resetStd( );
    resetCorr( );
    return
end

for i = 1 : numel(varargin)
    x = strip(string(varargin{i}));
    if any(startsWith(x, ["sstate", "steady"], "ignoreCase", true))
        resetSteady( );
    elseif startsWith(x, "plain", "ignoreCase", true)
        resetPlainParameters( );
    elseif startsWith(x, "param", "ignoreCase", true)
        resetPlainParameters( );
        resetStd( );
        resetCorr( );
    elseif startsWith(x, "stdcorr", "ignoreCase", true)
        resetStd( );
        resetCorr( );
    elseif startsWith(x, "std", "ignoreCase", true)
        resetStd( );
    elseif startsWith(x, "corr", "ignoreCase", true)
        resetCorr( );
    end
end

return

    function resetSteady( )
        this.Variant.Values(:, inxX | inxY, :) = NaN;
    end%


    function resetPlainParameters( )
        this.Variant.Values(:, inxP, :) = NaN;
    end%


    function resetStd( )
        this.Variant.StdCorr(:, 1:numE, :) = defaultStd;
    end%


    function resetCorr( )
        this.Variant.StdCorr(:, numE+1:end, :) = 0;
    end%
end%
