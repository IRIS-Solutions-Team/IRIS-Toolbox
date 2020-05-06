function blazerObj = prepareBlazer(this, isBlocks)
% prepareBlazer  Prepare blazer object for Explanatory simulation
% 
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

numEquations = numel(this);
lhsNames = [this(:).LhsName];

blazerObj = solver.blazer.ExplanatoryTerms( );
blazerObj.Model.Quantity = model.component.Quantity.fromNames(lhsNames);
blazerObj.Model.Equation = model.component.Equation.fromInput({this.Input});
blazerObj.InxEquations = true(1, numEquations);
blazerObj.InxEndogenous = true(1, numEquations);
blazerObj.IsBlocks = isBlocks;

%
% Set up the incidence matrix
%
allNames = {this(:).VariableNames};
inc = diag(true(1, numEquations));
for i = 1 : numEquations
    inc(i, ismember(lhsNames, allNames{i})) = true;
end
blazerObj.Incidence = inc;

end%

