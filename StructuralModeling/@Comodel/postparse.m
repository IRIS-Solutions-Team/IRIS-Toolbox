% postparse  Extra post tasks on top of model/postparse
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function this = postparse( ...
    this, qty, eqn, log, euc, puc, collector ...
    , opt, optimalOpt ...
    , condShocks, discount ...
);

stringify = @(x) reshape(string(x), 1, []);
names = stringify(qty.Name);

%
% Retype measurement variables and measurement shocks to transition
%
[qty, eqn] = locallyRetypeMeasurementToTransition(qty, eqn);


%
% Insert the name of the discount factor as a new variable if it does not
% exist in qty yet
%
qty = locallyEnsureDiscountParameter(qty, discount);


%
% Resolve attributes and retype conditioning shocks to transition
% variables; do this before creating new shocks for slacks because these
% would be included in the conditioning shocks if the user specifies @all
% Make sure the conditioning shocks do not become log-variables
%

condShocks = hereResolveCondShocks(condShocks);

for n = condShocks
    qty = retype(qty, n, 2);
end

if isa(log, 'Except')
    log.List = [log.List, condShocks];
end


%
% Create new shocks (slacks) slk_xxx where xxx is a regular kind of
% transition variable. These shocks are placed in the equations created by
% differentiating the Lagrangian wrt the variables, and used to relax these
% derivatives when conditioning the model simualtion on the observations of
% these variables.
%
[qty, posCondShocks] = locallyCreateSlacks(qty);


%
% Add parameters for std of conditioning shocks (turned transition
% variables) named costd_shock
%
costd = "costd_" + condShocks;
add = model.Quantity.fromNames(costd);
[qty, ~, ~, posCostd] = insert(qty, add, 4, 'last');

%
% Create loss function
%
loss = hereCreateLossFunc();

add = model.Equation.fromInput(loss);
[eqn, ~, ~, posLoss] = insert(eqn, add, 2, 'last');

add = parser.EquationUnderConstruction.forLoss(loss);
euc = insert(euc, add, [], posLoss);

% ========================================================================= 
this = postparse@Model( ...
    this, qty, eqn, log, euc, puc, collector, opt, optimalOpt ...
);
% ========================================================================= 

%
% qty and this.Quantity have changd in postparse@Model(), update the list
% of model names here for further use
%
names = stringify(this.Quantity.Name);
numQuantities = numel(names);


%
% Set up pairing of Slacks and Costds only after running postparse()
% because new names are being added to qty within it for optimal policy
% models and comodels
%
this.Pairing.Slacks = zeros(1, numQuantities);
posSlacks = find(startsWith(names, qty.SLACK_PREFIX));
namesVariables = extractAfter(names(posSlacks), qty.SLACK_PREFIX);
posVariables = double.empty(1, 0);
for n = namesVariables
    posVariables(end+1) = find(n==names);
end
this.Pairing.Slacks(posVariables) = posSlacks;

this.Pairing.Costds = zeros(1, numQuantities);
posCostds = find(startsWith(names, qty.COSTD_PREFIX));
namesShocks = extractAfter(names(posCostds), qty.COSTD_PREFIX);
posShocks = double.empty(1, 0);
for n = namesShocks
    posShocks(end+1) = find(n==names);
end
this.Pairing.Costds(posShocks) = posCostds;

return

    function outputCondShocks = hereResolveCondShocks(inputCondShocks)
        %(
        shockNames = stringify(qty.Name(qty.Type==32));
        if isequal(inputCondShocks, @all)
            outputCondShocks = shockNames;
            return
        end
        inputCondShocks = strip(stringify(inputCondShocks));
        outputCondShocks = string.empty(1, 0);
        for n = inputCondShocks
            if startsWith(n, ":")
                outputCondShocks = [outputCondShocks, byAttributes(qty, n)];
            else
                outputCondShocks = [outputCondShocks, n];
            end
        end
        outputCondShocks = unique(outputCondShocks, 'stable');
        outputCondShocks = intersect(outputCondShocks, shockNames, 'stable');
        %)
    end%


    function loss = hereCreateLossFunc()
        %(
        loss = "min(" + string(discount) + ") " + join(condShocks+"^2", "+");
        %)
    end%
end%

%
% Local functions
%

function [qty, eqn] = locallyRetypeMeasurementToTransition(qty, eqn)
    %(
    qty.Type(qty.Type==1) = 2;
    qty.Type(qty.Type==31) = 32;
    eqn.Type(eqn.Type==1) = 2;
    %)
end%


function qty = locallyEnsureDiscountParameter(qty, discount)
    %(
    if ~any(string(discount)==string(qty.Name))
        add = model.Quantity.fromNames(discount);
        add.Type = 4;
        qty = insert(qty, add, 4, 'last');
    end
    %)
end%


function [qty, posCondShocks] = locallyCreateSlacks(qty)
    %(
    inxVariablesNeedCond = qty.Type==2;
    numShocksToAdd = nnz(inxVariablesNeedCond);
    newShockNames = cellstr(string(qty.SLACK_PREFIX) + string(qty.Name(inxVariablesNeedCond)));
    add = model.Quantity.fromNames(newShockNames);
    [qty, ~, ~, posCondShocks] = insert(qty, add, 32, 'last');
    %)
end%

