function matrix = across(this, dim)

numOfShifts = length(this.Shift);
numOfEquations = size(this.Matrix, 1);
if numOfShifts>0
    numOfQuantities = size(this.Matrix, 2) / numOfShifts;
else
    numOfQuantities = 0;
end

if strncmpi(dim, 'Sh', 2) % Across all shifts.
    matrix = acrossShifts(this.Matrix);
elseif strncmpi(dim, 'La', 2) % Across all lags (negative shifts).
    matrix = acrossLags(this.Matrix);
elseif strncmpi(dim, 'Le', 2) % Across all leads (positive shifts).
    matrix = acrossLeads(this.Matrix);
elseif strncmpi(dim, 'No', 2) % Across all non-zero shifts (lags and leads).
    matrix = acrossNonzeros(this.Matrix);
elseif strncmpi(dim, 'Ze', 2) % At zero shift.
    matrix = atZero(this.Matrix);
elseif strncmpi(dim, 'Eq', 2) % Across all equations.
    matrix = acrossEquations(this.Matrix);
end

return


    function inx = acrossShifts(inx)
        inx = reshape(inx, numOfEquations*numOfQuantities, numOfShifts);
        inx = any(inx, 2);
        inx = reshape(inx, numOfEquations, numOfQuantities);
    end%


    function inx = acrossLags(inx)
        pos = find(this.Shift<0, 1, 'Last');
        inx = inx(:, 1:pos*numOfQuantities);
        inx = reshape(inx, numOfEquations*numOfQuantities, pos);
        inx = any(inx, 2);
        inx = reshape(inx, numOfEquations, numOfQuantities);
    end%


    function inx = acrossLeads(inx)
        pos = find(this.Shift>0, 1, 'First');
        inx = inx(:, (pos-1)*numOfQuantities+1:end);
        inx = reshape(inx, numOfEquations*numOfQuantities, max(0, numOfShifts-pos+1));
        inx = any(inx, 2);
        inx = reshape(inx, numOfEquations, numOfQuantities);
    end%


    function inx = acrossNonzeros(inx)
        pos = find(this.Shift==0);
        inx(:, (pos-1)*numOfQuantities+(1:numOfQuantities)) = [ ];
        inx = reshape(inx, numOfEquations*numOfQuantities, max(0, numOfShifts-1));
        inx = any(inx, 2);
        inx = reshape(inx, numOfEquations, numOfQuantities);
    end%


    function inx = atZero(inx)
        pos = find(this.Shift==0);        
        col = (pos-1)*numOfQuantities + (1:numOfQuantities);
        inx = inx(:, col);
    end%


    function inx = acrossEquations(inx)
        inx = any(inx, 1);
        inx = reshape(inx, numOfQuantities, numOfShifts);
    end%
end%

