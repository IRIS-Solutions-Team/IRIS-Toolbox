function this = reset(this, varargin)
% reset  Reset specific values within model object.
%
% Syntax
% =======
%
%     M = reset(M)
%     M = reset(M,Req1,Req2,...)
%
%
% Input arguments
% ================
%
% * `M` [ model ] -  Model object in which the requested type(s) of values
% will be reset.
%
% * `Req1`, `Req2`, ... [ `'corr'` | `'parameters'` | `'sstate'` | `'std'`
% | `'stdcorr'` ] - Requested type(s) of values that will be reset; if
% omitted, everything will be reset.
%
%
% Output arguments
% =================
%
% * `M` [ model ] - Model object with the requested values reset.
%
%
% Description
% ============
%
% * `'corr'` - All cross-correlation coefficients will be reset to `0`.
%
% * `'parameters'` - All parameters will be reset to `NaN`.
%
% * `'sstate'` - All steady state values will be reset to `NaN`.
%
% * `'std'` - All std deviations will be reset to `1` (in linear models) or
% `log(1.01)` (in non-linear models).
%
% * `'stdcorr'` - Equivalent to `'std'` and `'corr'`.
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
    defaultStd = 1;
else
    defaultStd = 0.01;
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
            this.Variant{iAlt}.StdCorr(:, 1:ne) = defaultStd;
        end
    end




    function resetCorr( )
        for iAlt = 1 : nAlt
            this.Variant{iAlt}.StdCorr(:, ne+1:end) = 0;
        end
    end
end
