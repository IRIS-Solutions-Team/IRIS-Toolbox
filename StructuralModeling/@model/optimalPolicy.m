function new = optimalPolicy(this, quantity, equation, ...
    posLossEqtn, lossDisc, posNnegName, posNnegMult, type)
% optimalPolicy  Derive equations for optimal policy.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%                      | Original   | With optimal    | With optimal
%                      |            |                 | and nonneg
%----------------------+------------+-----------------+---------------------
%                      |            |                 | 
%                      | Eq1   Var1 | Eq1:=dMu1  Mu1  | Eq1           Mu1
%                      | Eq2   Var2 | Eq2:=dMu2  Mu2  | Eq2           Mu2
% PosLossEqtn          | Loss  Var3 | dVar1      Var1 | Slack         MuNneg
%                      |       Var4 | dVar2      Var2 | dVar1         Var1
%          PosNnegName |       Var5 | dVar3      Var3 | dVar2=MuNneg  Var2
%                      |            | dVar4      Var4 | dVar3         Var3
%                      |            | dVar5      Var5 | dVar4         Var4
%                      |            |                 | dVar5         Var5

TYPE = @int8;

%--------------------------------------------------------------------------

new = struct( );

isNneg = ~isempty(posNnegName);
ixy = quantity.Type==TYPE(1);
ixx = quantity.Type==TYPE(2);
ixyx = ixy | ixx;
ixt = equation.Type==TYPE(2);
nEqtn = length(equation.Input);

eqtn = cell(1, nEqtn);
eqtn(:) = {''};
eqtn(ixx) = equation.Dynamic(ixx);

% Replace x(:,n,t+k) with xN, xNpK, or xNmK, and &x(n) with Ln.
eqtn = model.Gradient.array2symb(eqtn);
lossDisc = model.Gradient.array2symb(lossDisc);

% First transition equation.
first = find(ixt, 1);

% The loss function is always the last equation. After the loss function,
% there are empty place holders. The new equations will be put in place of
% the loss function and the placeholders.
new.Input = cell(size(eqtn));
new.Input(:) = {''};
new.IxHash = false(size(eqtn));

% The lagrangian is
%
%     Mu_Eq1*eqtn1 + Mu_Eq2*eqtn2 + ... + lossfunc.
%
% The new k-th (k runs only for the original transition variables) equation
% is the derivative of the lagrangian wrt to the k-th variable, and is
% given by
%
%     Mu_Eq1*diff(eqtn1,namek) + Mu_Eq2*diff(eqtn2,namek) + ...
%     + diff(lossfunc,namek) = 0.
%
% We loop over the equations, and build gradually the new equations from
% the individual derivatives.

% Get the list of all variables and shocks (current dates, lags, leads) in
% equations.
% ixyxe = quantity.Type==TYPE(1) ...
%     | quantity.Type==TYPE(2) ...
%     | quantity.Type==TYPE(31) ...
%     | quantity.Type==TYPE(32);

for eq = first : posLossEqtn
    vecWrt = find(this.Incidence.Dynamic, eq, ixx);

    if strcmpi(type, 'consistent') || strcmpi(type, 'discretion')
        % This is a consistent (discretionary) policy. We only
        % differentiate wrt to current dates or lags of transition
        % variables. Remove leads from the list of variables we will
        % differentiate wrt.
        vecWrt( imag(vecWrt)>0 ) = [ ];
    end
    nWrt = length(vecWrt);
    
    % Write a cellstr with the symbolic names of variables wrt which we will
    % differentiate.
    unknown = cell(1, nWrt);
    vecNm = real(vecWrt);
    vecSh = imag(vecWrt);
    for j = 1 : nWrt
        if vecSh(j)==0
            % Time index==0: replace x(1,23,t) with x23.
            unknown{j} = sprintf('x%g', vecNm(j));
        elseif vecSh(j)<0
            % Time index<0: replace x(1,23,t-1) with x23m1.
            unknown{j} = sprintf('x%gm%g', vecNm(j), -vecSh(j));
        elseif vecSh(j)>0
            % Time index>0: replace x(1,23,t+1) with x23p1.
            unknown{j} = sprintf('x%gp%g', vecNm(j), vecSh(j));
        end
    end
        
    d = Ad.diff(eqtn{eq}, unknown);
    d = strcat('(', d, ')');

    for j = 1 : nWrt

        newEq = vecNm(j);
        sh = vecSh(j);

        % Multiply derivatives wrt lags and leads by the discount factor.
        if sh==0
            % Do nothing.
        elseif sh==-1
            d{j} = [d{j}, '*(', lossDisc, ')'];
        elseif sh==1
            d{j} = [d{j}, '/(', lossDisc, ')'];
        else
            d{j} = [d{j}, '*(', lossDisc, ')^', sprintf('%g', -sh)];
        end
        
        % If this is not the loss function, multiply the derivative by the
        % respective multiplier. The appropriate lag or lead of the multiplier will
        % be introduced together with other variables.
        if eq<posLossEqtn
            mult = sprintf('x%g', eq);
            d{j} = [d{j}, '*', mult];
        end

        % Shift lags and leads of variables and multipliers (but not parameters) in
        % this derivative by -sh if sh~=0.
        if sh~=0
            d{j} = Ad.shiftBy(d{j}, -sh, ixyx);
        end
        
        sign = '+';
        if isempty(new.Input{newEq}) ...
                || strncmp(new.Input{newEq}, '-', 1) ...
                || strncmp(new.Input{newEq}, '+', 1)
            sign = '';
        end
        new.Input{newEq} = [d{j}, sign, new.Input{newEq}];

        % Earmark the derivative for non-linear simulation if at least one equation
        % in it is nonlinear and the derivative is nonzero. The derivative of the
        % loss function is supposed to be treated as nonlinear if the loss function
        % itself has been introduced by min#( ) and not min( ).
        isNonlin = equation.IxHash(eq) && ~isequal(dEqtn, '0');
        new.IxHash(newEq) = new.IxHash(newEq) || isNonlin;
        
    end
end

% Add nonnegativity multiplier to RHS of derivative wrt nonegative
% equation, and create complementary slack condition, which is always
% placed where loss function was.
if isNneg
    new.Input{posNnegName} = [new.Input{posNnegName}, sprintf('-x%g', posNnegMult)];
    new.Input{posLossEqtn} = sprintf('min(x%g,x%g)', posNnegName, posNnegMult);
    new.IxHash(posLossEqtn) = true;
end

new.Dynamic = model.Gradient.symb2array(new.Input);
new.Steady = model.Gradient.symb2array(new.Input);
new.Input = model.Gradient.symb2array(new.Input, 'input', quantity.Name);

% Add semicolons at the end of each new equation.
pos = posLossEqtn : length(new.Input);
new.Input(pos) = strcat(new.Input(pos), '=0;');
new.Dynamic(pos) = strcat(new.Dynamic(pos), ';');
new.Steady(pos) = strcat(new.Steady(pos), ';');

% Replace = with #= in nonlinear human equations.
new.Input(new.IxHash) = strrep(new.Input(new.IxHash), '=0;', '=#0;');
    
end
