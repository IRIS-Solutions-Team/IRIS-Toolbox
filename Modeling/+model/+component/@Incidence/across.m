function matrix = across(this, dim)

numShifts = length(this.Shift);
numEquations = size(this.Matrix, 1);
if numShifts>0
    numQuantities = size(this.Matrix, 2) / numShifts;
else
    numQuantities = 0;
end

if startsWith(dim, 'Sh', 'IgnoreCase', true) % Across all shifts.
    matrix = acrossShifts(this.Matrix);
elseif startsWith(dim, 'La','IgnoreCase', true) % Across all lags (negative shifts).
    matrix = acrossLags(this.Matrix);
elseif startsWith(dim, 'Le', 'IgnoreCase', true) % Across all leads (positive shifts).
    matrix = acrossLeads(this.Matrix);
elseif startsWith(dim, 'No', 'IgnoreCase', true) % Across all non-zero shifts (lags and leads).
    matrix = acrossNonzeros(this.Matrix);
elseif startsWith(dim, 'Ze', 'IgnoreCase', true) % At zero shift.
    matrix = atZero(this.Matrix);
elseif startsWith(dim, 'Eq', 'IgnoreCase', true) % Across all equations.
    matrix = acrossEquations(this.Matrix);
end

return


    function inx = acrossShifts(inx)
        inx = reshape(inx, numEquations*numQuantities, numShifts);
        inx = any(inx, 2);
        inx = reshape(inx, numEquations, numQuantities);
    end%


    function inx = acrossLags(inx)
        pos = find(this.Shift<0, 1, 'Last');
        inx = inx(:, 1:pos*numQuantities);
        inx = reshape(inx, numEquations*numQuantities, pos);
        inx = any(inx, 2);
        inx = reshape(inx, numEquations, numQuantities);
    end%


    function inx = acrossLeads(inx)
        pos = find(this.Shift>0, 1, 'First');
        inx = inx(:, (pos-1)*numQuantities+1:end);
        inx = reshape(inx, numEquations*numQuantities, max(0, numShifts-pos+1));
        inx = any(inx, 2);
        inx = reshape(inx, numEquations, numQuantities);
    end%


    function inx = acrossNonzeros(inx)
        pos = find(this.Shift==0);
        inx(:, (pos-1)*numQuantities+(1:numQuantities)) = [ ];
        inx = reshape(inx, numEquations*numQuantities, max(0, numShifts-1));
        inx = any(inx, 2);
        inx = reshape(inx, numEquations, numQuantities);
    end%


    function inx = atZero(inx)
        pos = find(this.Shift==0);        
        col = (pos-1)*numQuantities + (1:numQuantities);
        inx = inx(:, col);
    end%


    function inx = acrossEquations(inx)
        inx = any(inx, 1);
        inx = reshape(inx, numQuantities, numShifts);
    end%
end%

