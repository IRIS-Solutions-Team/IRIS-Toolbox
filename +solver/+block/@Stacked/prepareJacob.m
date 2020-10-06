function prepareJacob(this, varargin)

columnsToRun = this.ParentBlazer.ColumnsToRun;
numQuantities = numel(this.IdQuantities);

%
% Prepare the common part of the Jacobian; if these properties already
% exist they don't need to be updated because they are independent of the
% frame
%

% TODO
%if isempty(this.StackedJacob_GradientsMap)
    createGradientsMap(this);
    createGradientsFunc(this);
%end


%
% Prepare the terminal part of the Jacobian; the terminal part consists of
% equations+periods that reach into the terminal condition
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
    addEquation = string(this.ParentBlazer.Equations(ptrEquation));
    if ~endsWith(addEquation, ";")
        addEquation = addEquation + ";";
    end
    addEquation = replace(addEquation, ",t)", "," + string(column) + ")");
    addEquation = replace(addEquation, ",t+", "," + string(column) + "+");
    addEquation = replace(addEquation, ",t-", "," + string(column) + "-");
    equationsFuncUsingTerminal = equationsFuncUsingTerminal + addEquation;
end
equationsFuncUsingTerminal = str2func(this.PREAMBLE + "[" + equationsFuncUsingTerminal + "]");

this.StackedJacob_InxQuantitiesDeterminingTerminal = inxQuantitiesDeterminingTerminal;
this.StackedJacob_EquationsFuncUsingTerminal = equationsFuncUsingTerminal;

end%

