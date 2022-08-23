function matrix = across(this, dim)

numShifts = numel(this.Shift);
numEquations = size(this.Matrix, 1);
if numShifts>0
    numQuantities = size(this.Matrix, 2) / numShifts;
else
    numQuantities = 0;
end

if startsWith(dim, "Sh", "ignoreCase", true) % Across all shifts.
    matrix = acrossShifts(this.Matrix);
elseif startsWith(dim, "La","ignoreCase", true) % Across all lags (negative shifts).
    matrix = acrossLags(this.Matrix);
elseif startsWith(dim, "Le", "ignoreCase", true) % Across all leads (positive shifts).
    matrix = acrossLeads(this.Matrix);
elseif startsWith(dim, "No", "ignoreCase", true) % Across all non-zero shifts (lags and leads).
    matrix = acrossNonzeros(this.Matrix);
elseif startsWith(dim, "Ze", "ignoreCase", true) % At zero shift.
    matrix = atZero(this.Matrix);
elseif startsWith(dim, "Eq", "ignoreCase", true) % Across all equations.
    matrix = acrossEquations(this.Matrix);
elseif startsWith(dim, "Qu", "ignoreCase", true) % Across all quantities
    matrix = acrossQuantities(this.Matrix);
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

    function output = acrossQuantities(input)
        output = sparse(numEquations, 0);
        for sh = 1 : numShifts
            temp = input(:, (sh-1)*numQuantities+(1:numQuantities));
            output = [output, any(temp, 2)];
        end
    end%
end%

