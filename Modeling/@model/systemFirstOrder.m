function [syst, indexOfNaNDerivs, deriv] = systemFirstOrder(this, variantRequested, opt)
% systemFirstOrder  Calculate first-order system matrices
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

% opt.select
% opt.eqtn
% opt.symbolic

TYPE = @int8;

%--------------------------------------------------------------------------

% Select only the equations in which at least one parameter or steady state
% has changed since the last differentiation.
ixm = this.Equation.Type==TYPE(1);
ixt = this.Equation.Type==TYPE(2);
nm = sum(ixm);
nt = sum(ixt); 
eqSelect = affected(this, variantRequested, opt);
eqSelect = eqSelect & (ixm | ixt);

% Evaluate derivatives of equations wrt parameters
[deriv, indexOfNaNDerivs] = diffFirstOrder(this, eqSelect, variantRequested, opt);

% Set up system matrices from derivatives
getSystemMatrices( );

% Update handle to last system.
this.LastSystem.Values = this.Variant.Values(:, :, variantRequested);
this.LastSystem.Deriv = deriv;
this.LastSystem.System = syst;

return


    function getSystemMatrices( )
        posOfMeasurementEq = find(eqSelect(1:nm)); % Selected measurement equations.
        posOfTransitionEq = find(eqSelect(nm+1:end)); % Selected transition equations.
        [~, ~, ~, kf] = sizeOfSystem(this.Vector);
        D2S = this.D2S;
        
        syst = this.LastSystem.System;
        
        % __Measurement Equations__
        % A1 y + B1 xb' + E1 e + K1 = 0
        syst.K{1}(posOfMeasurementEq) = deriv.c(posOfMeasurementEq);
        syst.A{1}(posOfMeasurementEq, D2S.SystemY)      = deriv.f(posOfMeasurementEq, D2S.DerivY);
        % Measurement equations include only bwl variables; subtract
        % therefore the number of fwl variables from the positions of SystemXbMinus.
        syst.B{1}(posOfMeasurementEq, D2S.SystemXbMinus-kf) = deriv.f(posOfMeasurementEq, D2S.DerivXbMinus);
        syst.E{1}(posOfMeasurementEq, D2S.SystemE)      = deriv.f(posOfMeasurementEq, D2S.DerivE);
        
        % __Transition Equations__
        % A2 [xf' ; xb'] + B2 [xf ; xb] + E2 e + K2 = 0
        posOfTransitionEqInDeriv = nm + posOfTransitionEq;
        syst.K{2}(posOfTransitionEq) = deriv.c(posOfTransitionEqInDeriv);
        syst.A{2}(posOfTransitionEq, D2S.SystemXfMinus) = deriv.f(posOfTransitionEqInDeriv, D2S.DerivXfMinus);
        syst.A{2}(posOfTransitionEq, D2S.SystemXbMinus) = deriv.f(posOfTransitionEqInDeriv, D2S.DerivXbMinus);
        syst.B{2}(posOfTransitionEq, D2S.SystemXf)  = deriv.f(posOfTransitionEqInDeriv, D2S.DerivXf);
        syst.B{2}(posOfTransitionEq, D2S.SystemXb)  = deriv.f(posOfTransitionEqInDeriv, D2S.DerivXb);
        syst.E{2}(posOfTransitionEq, D2S.SystemE)   = deriv.f(posOfTransitionEqInDeriv, D2S.DerivE);
        
        % __Dynamic Identity Matrices__
        syst.A{2}(nt+1:end, :) = D2S.IdentityA;
        syst.B{2}(nt+1:end, :) = D2S.IdentityB;
        
        % __Effect of Add-Factors in Nonlinear Equations__
        syst.N{1} = [ ];
        syst.N{2}(posOfTransitionEq, :) = deriv.n(posOfTransitionEqInDeriv, :); 
    end%
end%
