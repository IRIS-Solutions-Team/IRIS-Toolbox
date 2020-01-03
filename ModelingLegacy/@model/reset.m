function this = reset(this, varargin)
% reset  Reset specific values within model object.
%
% ## Syntax ##
%
%     M = reset(M)
%     M = reset(M, Req1, Req2, ...)
%
%
% ## Input Arguments ##
%
% * `M` [ model ] -  Model object in which the requested type(s) of values
% will be reset.
%
% * `Req1`, `Req2`, ... [ `'Corr'` | `'Parameters'` | `'Sstate'` | `'Std'`
% | `'Stdcorr'` ] - Requested type(s) of values that will be reset; if
% omitted, everything will be reset.
%
%
% ## Output Arguments ##
%
% * `M` [ model ] - Model object with the requested values reset.
%
%
% ## Description ##
%
% * `'Corr'` - All cross-correlation coefficients will be reset to `0`.
%
% * `'Parameters'` - All parameters will be reset to `NaN`.
%
% * `'Sstate'` - All steady state values will be reset to `NaN`.
%
% * `'Std'` - All std deviations will be reset to `1` (in linear models) or
% `log(1.01)` (in non-linear models).
%
% * `'Stdcorr'` - Equivalent to `'Std'` and `'Corr'`.
%
%
% ## Example ##
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

TYPE = @int8;

%--------------------------------------------------------------------------
 
ixy = this.Quantity.Type==TYPE(1);
ixx = this.Quantity.Type==TYPE(2);
ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
ixp = this.Quantity.Type==TYPE(4);
ixg = this.Quantity.Type==TYPE(5);
ne = sum(ixe);

if this.IsLinear
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
    x = strtrim(varargin{i});
    if any(strcmpi(x, {'SState', 'SteadyState', 'Steady'}))
        resetSteady( );
    elseif strncmpi(x, 'PlainP', 6)
        resetPlainParameters( );
    elseif strncmpi(x, 'Param', 5)
        resetPlainParameters( );
        resetStd( );
        resetCorr( );
    elseif strcmpi(x, 'StdCorr')
        resetStd( );
        resetCorr( );
    elseif strcmpi(x, 'Std')
        resetStd( );
    elseif strcmpi(x, 'Corr')
        resetCorr( );
    end
end

return


    function resetSteady( )
        this.Variant.Values(:, ixx | ixy, :) = NaN;
    end%


    function resetPlainParameters( )
        this.Variant.Values(:, ixp, :) = NaN;
    end%


    function resetStd( )
        this.Variant.StdCorr(:, 1:ne, :) = defaultStd;
    end%


    function resetCorr( )
        this.Variant.StdCorr(:, ne+1:end, :) = 0;
    end%
end%
