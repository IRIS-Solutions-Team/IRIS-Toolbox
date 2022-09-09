function this = resetComment(this)

sizeData = size(this.Data);
this.Comment = strings([1, sizeData(2:end)]);

end%
