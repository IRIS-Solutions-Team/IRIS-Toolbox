% optimalPolicy  Derive equations for optimal policy
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function new = optimalPolicy( ...
    this, quantity, equation, posLossEqtn, lossDisc, ...
    posOfFloorVariable, posOfFloorMultiplier, posOfFloorParameter, type ...
)


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

stringify = @(x) reshape(string(x), 1, []);
names = stringify(quantity.Name);

new = struct( );

isFloor = ~isempty(posOfFloorVariable);
ixy = quantity.Type==1;
ixx = quantity.Type==2;
ixyx = ixy | ixx;
ixt = equation.Type==2;
nEqtn = numel(equation.Input);

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
%
%     ixyxe = quantity.Type==1 ...
%         | quantity.Type==2 ...
%         | quantity.Type==31 ...
%         | quantity.Type==32;

for eq = first : posLossEqtn
    vecWrt = find(this.Incidence.Dynamic, eq, ixx);

    if strcmpi(type, 'consistent') || strcmpi(type, 'discretion')
        % This is a consistent (discretionary) policy. We only
        % differentiate wrt to current dates or lags of transition
        % variables. Remove leads from the list of variables we will
        % differentiate wrt.
        vecWrt( imag(vecWrt)>0 ) = [ ];
    end
    numWrt = numel(vecWrt);

    % Write a cellstr with the symbolic names of variables wrt which we will
    % differentiate.
    vecPositions = real(vecWrt);
    vecShifts = imag(vecWrt);
    unknown = createListOfUnknowns(vecPositions, vecShifts);

    d = Ad.diff(eqtn{eq}, unknown);
    d = strcat('(', d, ')');

    for j = 1 : numWrt
        if strcmp(d{j}, '(0)')
            continue
        end

        wrtName = names(vecPositions(j));
        newEq = vecPositions(j);
        sh = vecShifts(j);

        % Earmark the derivative for non-linear simulation if at least one equation
        % in it is nonlinear and the derivative is nonzero. The derivative of the
        % loss function is supposed to be treated as nonlinear if the loss function
        % itself has been introduced by min#( ) and not min( ).
        new.IxHash(newEq) = new.IxHash(newEq) || equation.IxHash(eq);

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

        %
        % If this is not the loss function, multiply the derivative by 
        %
        % * the respective Lagrange multiplier,
        %
        % * the costd if applicable. 
        % 
        % The appropriate lag or lead of the multiplier will
        % be introduced together with other variables.
        %
        if eq<posLossEqtn
            mult = sprintf('*x%g', eq);

            costdName = "costd_" + wrtName;
            posCostd = find(costdName==names);
            costd = '';
            if ~isempty(posCostd)
                costd = sprintf('*x%g^2', posCostd);
            end

            d{j} = [d{j}, mult, costd];
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
    end
end


%
% To each derivative of the Lagrangian wrt a regular variable xxx (not a
% Lagrange multiplier, not a conditioning shock), add the shocks named
% slack_xxx used to condition the comodel simulations on the variable xxx
%
for pos = find(quantity.Type==2 & ~quantity.IxLagrange)
    condShockName = "slack_" + names(pos);
    posCondShock = find(condShockName==names);
    if isempty(posCondShock);
        continue
    end
    new.Input{pos} = [new.Input{pos}, sprintf('+x%g', posCondShock)];
end


% Add nonnegativity multiplier to RHS of derivative wrt nonegative
% equation, and create complementary slack condition, which is always
% placed where loss function was.
if isFloor
    new.Input{posOfFloorVariable} = [ ...
        new.Input{posOfFloorVariable} ...
        , sprintf('-x%g', posOfFloorMultiplier) ...
    ];
    new.Input{posLossEqtn} = sprintf( ...
        'min(x%g-x%g,x%g)' ...
        , posOfFloorVariable, posOfFloorParameter, posOfFloorMultiplier ...
    );
    new.IxHash(posLossEqtn) = true;
end

% Find multipliers that are always zero, and replace them with hard zeros
% in all equations.
new = simplifyZeroMultipliers(new);

new.Dynamic = model.Gradient.symb2array(new.Input);

% Replace steady-state references in steady equations
new.Steady = model.Gradient.symb2array(new.Input);
new.Steady = replace(new.Steady, 'L', 'x');

new.Input = model.Gradient.symb2array(new.Input, 'input', quantity.Name);

% Add semicolons at the end of each new equation
pos = posLossEqtn : numel(new.Input);
new.Input(pos) = strcat(new.Input(pos), '=0;');
new.Dynamic(pos) = strcat(new.Dynamic(pos), ';');
new.Steady(pos) = strcat(new.Steady(pos), ';');

% Replace = with #= in nonlinear human equations.
new.Input(new.IxHash) = strrep(new.Input(new.IxHash), '=0;', '=#0;');

end%


function unknown = createListOfUnknowns(vecPositions, vecShifts)
    numWrt = numel(vecPositions);
    unknown = cell(1, numWrt);
    for j = 1 : numWrt
        if vecShifts(j)==0
            % Time index==0: replace x(1,23,t) with x23.
            unknown{j} = sprintf('x%g', vecPositions(j));
        elseif vecShifts(j)<0
            % Time index<0: replace x(1,23,t-1) with x23m1.
            unknown{j} = sprintf('x%gm%g', vecPositions(j), -vecShifts(j));
        elseif vecShifts(j)>0
            % Time index>0: replace x(1,23,t+1) with x23p1.
            unknown{j} = sprintf('x%gp%g', vecPositions(j), vecShifts(j));
        end
    end
end%


function new = simplifyZeroMultipliers(new)
    numInput = numel(new.Input);
    [match, tokens] = regexp(new.Input, '^\(\-?1\)\*(x\d+)$', 'Match', 'Tokens', 'Once');
    indexFound = ~cellfun('isempty', match);
    for pos = find(indexFound)
        name = tokens{pos}{1};
        new.Input{pos} = name;
        new.IxHash(pos) = false;
        otherEquations = 1 : numInput;
        otherEquations(pos) = [ ];
        new.Input(otherEquations) = regexprep( ...
            new.Input(otherEquations), ['\<', name, '([pm]\d+)?\>'], '0' ...
        );
    end
end%

