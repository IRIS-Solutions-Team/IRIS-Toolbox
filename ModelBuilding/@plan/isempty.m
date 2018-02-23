function flag = isempty(this, query)

switch query
    case 'tunes'
        flag = nnz(this.XAnch) == 0 ...
            || nnz(this.NAnchReal) + nnz(this.NAnchImag) == 0;
    case 'cond'
        flag = nnz(this.CAnch) == 0;
    case 'range'
        flag = isempty(this.Start) || isempty(this.End);
end

end
