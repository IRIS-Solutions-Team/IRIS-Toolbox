function id = getIdOfInitialConditions(this)

TYPE = @int8;

%--------------------------------------------------------------------------

[ny, nxi, nb, nf] = sizeOfSolution(this);
inxOfX = getIndexByType(this.Quantity, TYPE(2));
idOfXib = this.Vector.Solution{2}(nf+1:end);

% Get numOfQuants-by-numOfShifts incidence matrix
incidence = across(this.Incidence.Dynamic, 'Equations');
posOfZeroShift = this.Incidence.Dynamic.PosOfZeroShift;

incidence(~inxOfX, :) = false;

% Move t-1 to the first plane, t-2 to the second plane, etc.
incidence = fliplr(incidence(:, 1:posOfZeroShift-1));

for row = find(inxOfX)
    maxLag = find(incidence(row, :), 1, 'last');
    if isempty(maxLag)
        continue
    end
    incidence(row, 1:maxLag) = true;
end

% Incidence
[name, shift] = find(incidence);
id = name - 1i*shift;

end%

