function [hashEquationsAsFunction, numOfHasEquations] = prepareHashEquations(this, rect, data)

% Function to evaluate hash equations
eqtn = [ this.Equation.Dynamic{this.Equation.InxOfHashEquations} ];
eqtn = [ '[', vectorize(eqtn), ']', ];
rect.HashEquationsFunction = str2func([this.PREAMBLE_DYNAMIC, eqtn]);

% Incidence of YX across hash equations
inxOfHashEquations = this.Equation.InxOfHashEquations;
hashIncidence = selectEquation(this.Incidence.Dynamic, inxOfHashEquations);
hashIncidence = removeTrailingShifts(hashIncidence);
rect.HashIncidence = hashIncidence;

data.NonlinAddf = zeros(nnz(inxOfHashEquations), data.NumOfColumns);

end%
