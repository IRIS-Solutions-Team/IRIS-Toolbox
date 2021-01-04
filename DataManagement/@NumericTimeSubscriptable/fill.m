% fill  Safely replace time series data 
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function this = fill(this, newData, newStart, newComment, newUserData)

this.Data = newData;

if nargin>2
    newStart = double(newStart);
    if numel(newStart)>1
        newStart = newStart(1);
    end
    this.Start = newStart;
end

this = resetComment(this);
if nargin>3 
    if iscell(newComment)
        indexEmpty = cellfun('isempty', newComment);
        if any(~indexEmpty)
            newComment(indexEmpty) = { TimeSubscriptable.EMPTY_COMMENT };
            this.Comment(:) = newComment(:);
        end
    elseif ischar(newComment) && ~isempty(newComment)
        this.Comment(:) = { newComment };
    end
end

if nargin>4
    this = userdata(this, newUserData);
end

this = resetMissingValue(this, this.Data);
this = trim(this);

end%

