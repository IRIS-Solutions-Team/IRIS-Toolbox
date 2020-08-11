function this = fill(this, newData, newStart, newComment, newUserData)
% fill  Safely replace time series data 
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

this.Data = newData;

if nargin>2
    if numel(newStart)>1
        newStart = double(newStart);
        newStart = newStart(1);
    end
    % Make new start date the same class as the old start date
    if isa(this.Start, 'DateWrapper') && ~isa(newStart, 'DateWrapper')
        newStart = DateWrapper(newStart);
    elseif isa(this.Start, 'double') && ~isa(newStart, 'double')
        newStart = double(newStart);
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

