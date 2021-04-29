% getIdInitialConditions  Get positions and shifts of initial conditions
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

function idInit = getIdInitialConditions(this)

TYPE = @int8;

%--------------------------------------------------------------------------

inxX = getIndexByType(this.Quantity, TYPE(2));

% Get numQuants-by-numShifts incidence matrix
incidence = across(this.Incidence.Dynamic, 'Equations');
posZeroShift = this.Incidence.Dynamic.PosZeroShift;

incidence(~inxX, :) = false;

% Move t-1 to the first plane, t-2 to the second plane, etc.
incidence = fliplr(incidence(:, 1:posZeroShift-1));

for row = find(inxX)
    maxLag = find(incidence(row, :), 1, 'last');
    if isempty(maxLag)
        continue
    end
    incidence(row, 1:maxLag) = true;
end

% Incidence
[name, shift] = find(incidence);
idInit = name - 1i*shift;

end%

