function prepareJacob(this, varargin)

columnsToRun = this.ParentBlazer.ColumnsToRun;
numQuantities = numel(this.IdQuantities);

%
% Prepare the common part of the Jacobian; if these properties already
% exist, verify if they really need to be recalculated. Recalculation is
% not needed if IdQuantities and IdEquations is the same as at the time of
% their previous calcuation except for a constant time shift.
%
needsCreateGradientsMap = ...
    isempty(this.StackedJacob_GradientsMap) ...
    || ~locallyConsistent(this.IdQuantities, this.StackedJacob_IdQuantitiesWhenMapped) ...
    || ~locallyConsistent(this.IdEquations, this.StackedJacob_IdEquationsWhenMapped);

if needsCreateGradientsMap
    createGradientsMap(this);
    createGradientsFunc(this);
end


%
% Prepare the terminal part of the Jacobian; the terminal part consists of
% equations+periods that reach into the terminal condition
%

sh0 = this.ParentBlazer.Incidence.PosZeroShift;
inxQuantitiesDeterminingTerminal = false(1, numQuantities);
if any(this.InxEquationsUsingTerminal)
    % Incidence matrix numQuantities-by-numShifts
    incQuantitiesShifts = across(this.ParentBlazer.Incidence, "Equations");

    maxLag = zeros(1, numQuantities);
    for i = 1 : numQuantities
        name = real(this.IdQuantities(i));
        maxLag(i) = find(incQuantitiesShifts(name, :), 1) - sh0;
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

%
% Local Functions
%

function flag = locallyConsistent(id1, id2)
    if numel(id1)~=numel(id2)
        flag = false;
        return
    end
    t1 = imag(id1(1));
    t2 = imag(id2(1));
    flag = isequal(real(id1), real(id2)) && isequal(imag(id1)-t1, imag(id2)-t2);
end%

