function idInit = getIdOfInitialConditions(this)
% getIdOfInitialConditions  Get positions and shifts of initial conditions
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

TYPE = @int8;

%--------------------------------------------------------------------------

inxX = getIndexByType(this.Quantity, TYPE(2));

% Get numQuants-by-numShifts incidence matrix
incidence = across(this.Incidence.Dynamic, 'Equations');
posZeroShift = this.Incidence.Dynamic.PosOfZeroShift;

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

