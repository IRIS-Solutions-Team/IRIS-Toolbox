function [syst, ixNanDeriv, deriv] = systemFirstOrder(this, iAlt, opt)
% systemFirstOrder  Calculate first-order system matrices.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

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
eqSelect = affected(this, iAlt, opt);
eqSelect = eqSelect & (ixm | ixt);

% Evaluate derivatives of equations wrt parameters
%--------------------------------------------------
[deriv, ixNanDeriv] = diffFirstOrder(this, eqSelect, iAlt, opt);

% Set up system matrices from derivatives
%-----------------------------------------
getSystemMatrices( );

% Update handle to last system.
this.LastSystem.Quantity = this.Variant{iAlt}.Quantity;
this.LastSystem.Deriv = deriv;
this.LastSystem.System = syst;

return




    function getSystemMatrices( )
        posm = find(eqSelect(1:nm)); % Selected measurement equations.
        post = find(eqSelect(nm+1:end)); % Selected transition equations.
        [~, ~, ~, kf] = sizeOfSystem(this.Vector);
        d2s = this.d2s;
        
        syst = this.LastSystem.System;
        
        % Measurement equations
        %------------------------
        % A1 y + B1 xb' + E1 e + K1 = 0
        syst.K{1}(posm) = deriv.c(posm);
        syst.A{1}(posm, d2s.y) = deriv.f(posm, d2s.y_);
        % Measurement equations include only bwl variables; subtract
        % therefore the number of fwl variables from the positions of xp1.
        syst.B{1}(posm, d2s.xp1-kf) = deriv.f(posm, d2s.xp1_);
        syst.E{1}(posm, d2s.e) = deriv.f(posm, d2s.e_);
        
        % Transition equations
        %----------------------
        % A2 [xf' ; xb'] + B2 [xf ; xb] + E2 e + K2 = 0
        post_ = nm + post;
        syst.K{2}(post) = deriv.c(post_);
        syst.A{2}(post, d2s.xu1) = deriv.f(post_, d2s.xu1_);
        syst.A{2}(post, d2s.xp1) = deriv.f(post_, d2s.xp1_);
        syst.B{2}(post, d2s.xu) = deriv.f(post_, d2s.xu_);
        syst.B{2}(post, d2s.xp) = deriv.f(post_, d2s.xp_);
        syst.E{2}(post, d2s.e) = deriv.f(post_, d2s.e_);
        
        % Add dynamic identity matrices
        %-------------------------------
        syst.A{2}(nt+1:end, :) = d2s.ident1;
        syst.B{2}(nt+1:end, :) = d2s.ident;
        
        % Effect of nonlinear equations
        %--------------------------------
        syst.N{1} = [ ];
        syst.N{2}(post, :) = deriv.n(post_, :); 
    end
end
