function this = shift(this, sh)

if isempty(this) || isempty(sh) || isequal(sh, 0)
    return
end

if isscalar(sh)
    this.Start = dater.plus(this.Start, -sh);
    return
end

sh = reshape(double(sh), 1, [ ]);
maxSh0 = max([sh, 0]);
minSh0 = min([sh, 0]);

sizeData = size(this.Data);
ndimsData = ndims(this.Data);
sizeTemplateData = sizeData;
sizeTemplateData(1) = sizeTemplateData(1)-minSh0+maxSh0;
templateData = nan(sizeTemplateData);
ref = cell(1, ndimsData);
ref(:) = {':'};
ref(2) = {[ ]};
newData = templateData(ref{:});
t = maxSh0 + (1 : sizeData(1));
for i = 1 : numel(sh)
    addData = templateData;
    addData(t-sh(i), :) = this.Data(:, :);
    newData = [newData, addData];
end
this.Data = newData;
this = trim(this);
this = resetComment(this);

end%
