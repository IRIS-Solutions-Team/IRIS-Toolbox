function [hashEquationsAsFunction, numOfHasEquations] = prepareHashEquations(this)

eqtn = [ this.Equation.Dynamic{this.Equation.InxOfHashEquations} ];
eqtn = [ '[', vectorize(eqtn), ']', ];
hashEquationsAsFunction = str2func([this.PREAMBLE_DYNAMIC, eqtn]);
numOfHasEquations = nnz(this.Equation.InxOfHashEquations);

end%
