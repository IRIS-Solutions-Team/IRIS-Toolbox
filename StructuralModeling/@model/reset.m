function this = reset(this, varargin)
% reset  Reset specific values within model object.
%
% Syntax
% =======
%
%     m = reset(m)
%     m = reset(m, req1, req2, ...)
%
%
% Input arguments
% ================
%
% * `m` [ model ] -  Model object in which the requested type(s) of values
% will be reset.
%
% * `req1`, `req2`, ... [ `'Corr'` | `'Parameters'` | `'Sstate'` | `'Std'`
% | `'Stdcorr'` ] - Requested type(s) of values that will be reset; if
% omitted, everything will be reset.
%
%
% Output arguments
% =================
%
% * `m` [ model ] - Model object with the requested values reset.
%
%
% Description
% ============
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
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

%--------------------------------------------------------------------------
 
ixy = this.Quantity.Type==TYPE(1);
ixx = this.Quantity.Type==TYPE(2);
ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
ixp = this.Quantity.Type==TYPE(4);
ixg = this.Quantity.Type==TYPE(5);
ne = sum(ixe);
nAlt = length(this.Variant);

if this.IsLinear
    dftStd = this.DEFAULT_STD_LINEAR;
else
    dftStd = this.DEFAULT_STD_NONLINEAR;
end

if isempty(varargin)
    resetSteady( );
    resetParams( );
    resetStd( );
    resetCorr( );
    return
end

for i = 1 : length(varargin)
    x = lower(strtrim(varargin{i}));
    switch lower(strtrim(x))
        case {'sstate', 'steadystate', 'steady'}
            resetSteady( );
        case {'plainparameters', 'plainparams'}
            resetParams( );
        case {'parameters', 'params'}
            resetParams( );
            resetStd( );
            resetCorr( );
        case 'stdcorr'
            resetStd( );
            resetCorr( );
        case 'std'
            resetStd( );
        case 'corr'
            resetCorr( );
    end
end

return




    function resetSteady( )
        for iAlt = 1 : nAlt
            this.Variant{iAlt}.Quantity(1, ixx | ixy) = NaN;
            this.Variant{iAlt}.Quantity(1, ixe) = 0;
            this.Variant{iAlt}.Quantity(1, ixg) = model.DEFAULT_STEADY_EXOGENOUS;
        end
    end




    function resetParams( )
        for iAlt = 1 : nAlt
            this.Variant{iAlt}.Quantity(1, ixp) = NaN;
        end
    end




    function resetStd( )
        for iAlt = 1 : nAlt
            this.Variant{iAlt}.StdCorr(:, 1:ne) = dftStd;
        end
    end




    function resetCorr( )
        for iAlt = 1 : nAlt
            this.Variant{iAlt}.StdCorr(:, ne+1:end) = 0;
        end
    end
end
