function this = fill(this, newData, newStart, newComment, newUserData)
% fill  Safely replace time series data 
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

%--------------------------------------------------------------------------

this.Data = newData;

if nargin>2
    if numel(newStart)>1
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

this = resetColumnNames(this);
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

this = trim(this);

end
