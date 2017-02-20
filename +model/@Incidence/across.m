function matrix = across(this, dim)

nsh = length(this.Shift);
nEqtn = size(this.Matrix, 1);
nQuan = size(this.Matrix, 2) / nsh;

if strncmpi(dim, 'Sh', 2) % Across all shifts.
    matrix = acrossShift(this.Matrix);
elseif strncmpi(dim, 'La', 2) % Across all lags (negative shifts).
    matrix = acrossLag(this.Matrix);
elseif strncmpi(dim, 'Le', 2) % Across all leads (positive shifts).
    matrix = acrossLead(this.Matrix);
elseif strncmpi(dim, 'No', 2) % Across all non-zero shifts (lags and leads).
    matrix = acrossNonzero(this.Matrix);
elseif strncmpi(dim, 'Ze', 2) % At zero shift.
    matrix = atZero(this.Matrix);
elseif strncmpi(dim, 'Eq', 2) % Across all equations.
    matrix = acrossEqtn(this.Matrix);
end

return




    function ix = acrossShift(ix)
        ix = reshape(ix, nEqtn*nQuan, nsh);
        ix = any(ix, 2);
        ix = reshape(ix, nEqtn, nQuan);
    end




    function ix = acrossLag(ix)
        pos = find(this.Shift<0, 1, 'Last');
        ix = ix(:, 1:pos*nQuan);
        ix = reshape(ix, nEqtn*nQuan, pos);
        ix = any(ix, 2);
        ix = reshape(ix, nEqtn, nQuan);
    end




    function ix = acrossLead(ix)
        pos = find(this.Shift>0, 1, 'First');
        ix = ix(:, (pos-1)*nQuan+1:end);
        ix = reshape(ix, nEqtn*nQuan, nsh-pos+1);
        ix = any(ix, 2);
        ix = reshape(ix, nEqtn, nQuan);
    end




    function ix = acrossNonzero(ix)
        pos = find(this.Shift==0);
        ix(:, (pos-1)*nQuan+(1:nQuan)) = [ ];
        ix = reshape(ix, nEqtn*nQuan, nsh-1);
        ix = any(ix, 2);
        ix = reshape(ix, nEqtn, nQuan);
    end




    function ix = atZero(ix)
        pos = find(this.Shift==0);        
        col = (pos-1)*nQuan + (1:nQuan);
        ix = ix(:, col);
    end




    function ix = acrossEqtn(ix)
        ix = any(ix, 1);
        ix = reshape(ix, nQuan, nsh);
    end
end
