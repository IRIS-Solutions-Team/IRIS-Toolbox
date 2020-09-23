% systemFirstOrder  Calculate first-order system matrices
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function [syst, inxNaNDerivs, deriv] = systemFirstOrder(this, variantRequested, opt)

% opt.Select
% opt.Eqtn
% opt.Symbolic

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
[deriv, inxNaNDerivs] = diffFirstOrder(this, eqSelect, variantRequested, opt);

% Set up system matrices from derivatives
hereGetSystemMatrices( );

% Update handle to last system.
this.LastSystem.Values = this.Variant.Values(:, :, variantRequested);
this.LastSystem.Deriv = deriv;
this.LastSystem.System = syst;

return

    function hereGetSystemMatrices( )
        posMeasurementEq = find(eqSelect(1:nm)); % Selected measurement equations.
        posTransitionEq = find(eqSelect(nm+1:end)); % Selected transition equations.
        [~, ~, ~, kf] = sizeSystem(this.Vector);
        D2S = this.D2S;
        
        syst = this.LastSystem.System;
        
        % __Measurement Equations__
        % A1 y + B1 xb' + E1 e + K1 = 0
        syst.K{1}(posMeasurementEq) = deriv.c(posMeasurementEq);
        syst.A{1}(posMeasurementEq, D2S.SystemY)      = deriv.f(posMeasurementEq, D2S.DerivY);
        % Measurement equations include only bwl variables; subtract
        % therefore the number of fwl variables from the positions of SystemXbMinus.
        syst.B{1}(posMeasurementEq, D2S.SystemXbMinus-kf) = deriv.f(posMeasurementEq, D2S.DerivXbMinus);
        syst.E{1}(posMeasurementEq, D2S.SystemE)      = deriv.f(posMeasurementEq, D2S.DerivE);
        
        % __Transition Equations__
        % A2 [xf' ; xb'] + B2 [xf ; xb] + E2 e + K2 = 0
        posTransitionEqInDeriv = nm + posTransitionEq;
        syst.K{2}(posTransitionEq) = deriv.c(posTransitionEqInDeriv);
        syst.A{2}(posTransitionEq, D2S.SystemXfMinus) = deriv.f(posTransitionEqInDeriv, D2S.DerivXfMinus);
        syst.A{2}(posTransitionEq, D2S.SystemXbMinus) = deriv.f(posTransitionEqInDeriv, D2S.DerivXbMinus);
        syst.B{2}(posTransitionEq, D2S.SystemXf)  = deriv.f(posTransitionEqInDeriv, D2S.DerivXf);
        syst.B{2}(posTransitionEq, D2S.SystemXb)  = deriv.f(posTransitionEqInDeriv, D2S.DerivXb);
        syst.E{2}(posTransitionEq, D2S.SystemE)   = deriv.f(posTransitionEqInDeriv, D2S.DerivE);
        
        % __Dynamic Identity Matrices__
        syst.A{2}(nt+1:end, :) = D2S.IdentityA;
        syst.B{2}(nt+1:end, :) = D2S.IdentityB;
        
        % __Effect of Add-Factors in Nonlinear Equations__
        syst.N{1} = [ ];
        syst.N{2}(posTransitionEq, :) = deriv.n(posTransitionEqInDeriv, :); 
    end%
end%

