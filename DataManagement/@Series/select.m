function this = select(this, varargin)

sz = size(this.data);
nPer = sz(1);
nd = length(sz);
this.data = this.data(:, :);

for i = 1 : size(this.data, 2)
    ixKeep = false(nPer, 1);
    colData = this.data(:, i);
    for j = 1 : length(varargin)
        x = varargin{j}(colData);
        ixKeep = ixKeep | colData==x;
    end
    this.data(~ixKeep, i) = NaN;
end

if nd>2
    this.data = reshape(this.data, [size(this.data, 1), sz(2:end)]);
end

this = trim(this);

end