function this = transpose(this)

rowNames = this.RowNames;
colNames = this.ColNames;

this = double(this);
n = ndims(this);
this = permute(this, [2, 1, 3:n]);

this = namedmat(this, colNames, rowNames);

end%

