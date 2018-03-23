function matrix = across(this, dim)

numShifts = length(this.Shift);
numEquations = size(this.Matrix, 1);
if numShifts>0
    numQuantities = size(this.Matrix, 2) / numShifts;
else
    numQuantities = 0;
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


    function ix = acrossShifts(ix)
        ix = reshape(ix, numEquations*numQuantities, numShifts);
        ix = any(ix, 2);
        ix = reshape(ix, numEquations, numQuantities);
    end


    function ix = acrossLags(ix)
        pos = find(this.Shift<0, 1, 'Last');
        ix = ix(:, 1:pos*numQuantities);
        ix = reshape(ix, numEquations*numQuantities, pos);
        ix = any(ix, 2);
        ix = reshape(ix, numEquations, numQuantities);
    end


    function ix = acrossLeads(ix)
        pos = find(this.Shift>0, 1, 'First');
        ix = ix(:, (pos-1)*numQuantities+1:end);
        ix = reshape(ix, numEquations*numQuantities, max(0, numShifts-pos+1));
        ix = any(ix, 2);
        ix = reshape(ix, numEquations, numQuantities);
    end


    function ix = acrossNonzeros(ix)
        pos = find(this.Shift==0);
        ix(:, (pos-1)*numQuantities+(1:numQuantities)) = [ ];
        ix = reshape(ix, numEquations*numQuantities, max(0, numShifts-1));
        ix = any(ix, 2);
        ix = reshape(ix, numEquations, numQuantities);
    end


    function ix = atZero(ix)
        pos = find(this.Shift==0);        
        col = (pos-1)*numQuantities + (1:numQuantities);
        ix = ix(:, col);
    end


    function ix = acrossEquations(ix)
        ix = any(ix, 1);
        ix = reshape(ix, numQuantities, numShifts);
    end
end
