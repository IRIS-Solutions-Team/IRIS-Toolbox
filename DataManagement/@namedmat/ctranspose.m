function this = ctranspose(this)
    
rowNames = this.RowNames;
colNames = this.ColNames;

this = double(this);
n = ndims(this);
realX = real(this);
imagX = imag(this);
realX = permute(realX, [2, 1, 3:n]);
imagX = permute(imagX, [2, 1, 3:n]);
this = realX - 1i*imagX;

this = namedmat(this, colNames, rowNames);

end%

