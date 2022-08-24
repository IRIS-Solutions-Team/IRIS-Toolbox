function this = createAffected(this)

numEquations = length(this.Equation);
numQuantities = length(this.Quantity);
minShift = this.Incidence.Dynamic.Shift(1) + 1;
maxShift = this.Incidence.Dynamic.Shift(end) - 1;
indexMT = this.Equation.Type==1 | this.Equation.Type==2;

steadyRef = model.Incidence(numEquations, numQuantities, minShift, maxShift);
steadyRef = fill(steadyRef, this.Quantity, this.Equation.Dynamic, indexMT, 'L');

this.Affected = across(this.Incidence.Dynamic, 'Shifts') | across(steadyRef, 'Shifts');

end
