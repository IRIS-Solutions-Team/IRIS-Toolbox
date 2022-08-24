function this = fill(this, newData, newStart, newComment, newUserData)

oldClass = class(this.Data);
newClass = class(newData);

this.Data = newData;

if nargin>=3
    newStart = double(newStart);
    if numel(newStart)>1
        newStart = newStart(1);
    end
    this.Start = newStart;
end

% Reset comments
sizeComment = size(newData);
sizeComment(1) = 1;
if nargin>=4
    newComment = string(newComment);
    if numel(newComment)==1 && any(sizeComment>1)
        temp = newComment;
        newComment = strings(sizeComment);
        newComment(:) = temp;
    end
    this.Comment = newComment;
else
    this.Comment = strings(sizeComment);
end

if nargin>=5
    this = userdata(this, newUserData);
end

if ~isequal(oldClass, newClass)
    this = resetMissingValue(this, this.Data);
end

if isempty(newData)
    return
end

if isequaln(this.MissingTest, @isnan)
    inxAllMissing = all(isnan(newData(:, :)), 2);
else
    inxAllMissing = all(this.MissingTest(newData(:, :)), 2);
end

if inxAllMissing(1) || inxAllMissing(end)
    this = trim(this, inxAllMissing);
end

end%

