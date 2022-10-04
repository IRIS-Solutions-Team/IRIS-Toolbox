% systemFirstOrder  Calculate first-order system matrices
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function [syst, inxNaNDerivs, deriv] = systemFirstOrder(this, variantRequested, opt)

% opt.ForceDiff
% opt.Eqtn
% opt.Symbolic

% Select only the equations in which at least one parameter or steady state
% has changed since the last differentiation.
inxM = this.Equation.Type==1;
inxT = this.Equation.Type==2;
numM = nnz(inxM);
numT = nnz(inxT);

inxToDiff = affected(this, variantRequested, opt);
inxToDiff = inxToDiff & (inxM | inxT);

% Evaluate derivatives of equations wrt parameters
[deriv, inxNaNDerivs] = diffFirstOrder(this, inxToDiff, variantRequested, opt);

% Set up system matrices from derivatives
here_getSystemMatrices( );

% Update handle to last system.
this.LastSystem.Values = this.Variant.Values(:, :, variantRequested);
this.LastSystem.Deriv = deriv;
this.LastSystem.System = syst;

return

    function here_getSystemMatrices( )
        posMeasurementEq = find(inxToDiff(1:numM)); % Selected measurement equations.
        posTransitionEq = find(inxToDiff(numM+1:end)); % Selected transition equations.
        [~, ~, ~, kf] = sizeSystem(this.Vector);
        D2S = this.D2S;

        syst = this.LastSystem.System;

        % __Measurement Equations__
        % A1 y + B1 xb' + E1 e + K1 = 0
        syst.K{1}(posMeasurementEq) = deriv.c(posMeasurementEq);
        syst.A{1}(posMeasurementEq, D2S.SystemY) = deriv.f(posMeasurementEq, D2S.DerivY);
        % Measurement equations include only bwl variables; subtract
        % therefore the number of fwl variables from the positions of SystemXbMinus.
        syst.B{1}(posMeasurementEq, D2S.SystemXbMinus-kf) = deriv.f(posMeasurementEq, D2S.DerivXbMinus);
        syst.E{1}(posMeasurementEq, D2S.SystemE) = deriv.f(posMeasurementEq, D2S.DerivE);

        % __Transition Equations__
        % A2 [xf' ; xb'] + B2 [xf ; xb] + E2 e + K2 = 0
        posTransitionEqInDeriv = numM + posTransitionEq;
        syst.K{2}(posTransitionEq) = deriv.c(posTransitionEqInDeriv);
        syst.A{2}(posTransitionEq, D2S.SystemXfMinus) = deriv.f(posTransitionEqInDeriv, D2S.DerivXfMinus);
        syst.A{2}(posTransitionEq, D2S.SystemXbMinus) = deriv.f(posTransitionEqInDeriv, D2S.DerivXbMinus);
        syst.B{2}(posTransitionEq, D2S.SystemXf) = deriv.f(posTransitionEqInDeriv, D2S.DerivXf);
        syst.B{2}(posTransitionEq, D2S.SystemXb) = deriv.f(posTransitionEqInDeriv, D2S.DerivXb);
        syst.E{2}(posTransitionEq, D2S.SystemE) = deriv.f(posTransitionEqInDeriv, D2S.DerivE);

        % __Dynamic Identity Matrices__
        syst.A{2}(numT+1:end, :) = D2S.IdentityA;
        syst.B{2}(numT+1:end, :) = D2S.IdentityB;

        % __Effect of Add-Factors in Nonlinear Equations__
        syst.N{1} = [ ];
        syst.N{2}(posTransitionEq, :) = deriv.n(posTransitionEqInDeriv, :);
    end%
end%

