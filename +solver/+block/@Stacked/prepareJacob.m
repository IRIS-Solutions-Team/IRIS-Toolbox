function prepareJacob(this, varargin)

columnsToRun = this.ParentBlazer.ColumnsToRun;
numQuantities = numel(this.IdQuantities);

%
% Prepare the common part of the Jacobian
%
createGradientsMap(this);
createGradientsFunc(this);

%
% Prepare the terminal part of the Jacobian
%

sh0 = this.ParentBlazer.Incidence.PosOfZeroShift;
inxQuantitiesDeterminingTerminal = false(1, numQuantities);
if any(this.InxEquationsUsingTerminal)
    % Incidence matrix numQuantities-by-numShifts
    incQuantitiesShifts = across(this.ParentBlazer.Incidence, "Equations");

    maxLag = zeros(1, numQuantities);
    for i = 1 : numQuantities
        name = real(this.IdQuantities(i));
        maxLag(i) = find(incQuantitiesShifts(name, :), 1, "first") - sh0;
    end
    inxQuantitiesDeterminingTerminal = imag(this.IdQuantities) - maxLag > columnsToRun(end);
end

if ~any(this.InxEquationsUsingTerminal) || ~any(inxQuantitiesDeterminingTerminal)
    return
end

equationsFuncUsingTerminal = "";
for i = find(this.InxEquationsUsingTerminal)
    ptrEquation = real(this.IdEquations(i));
    column = imag(this.IdEquations(i));
    temp = string(this.ParentBlazer.Equations(ptrEquation));
    if ~endsWith(temp, ";")
        temp = temp + ";";
    end
    temp = replace(temp, ",t)", "," + string(column) + ")");
    temp = replace(temp, ",t+", "," + string(column) + "+");
    temp = replace(temp, ",t-", "," + string(column) + "-");
    equationsFuncUsingTerminal = equationsFuncUsingTerminal + temp;
end
equationsFuncUsingTerminal = str2func(this.PREAMBLE + "[" + equationsFuncUsingTerminal + "]");

this.StackedJacob_InxQuantitiesDeterminingTerminal = inxQuantitiesDeterminingTerminal;
this.StackedJacob_EquationsFuncUsingTerminal = equationsFuncUsingTerminal;

end%

