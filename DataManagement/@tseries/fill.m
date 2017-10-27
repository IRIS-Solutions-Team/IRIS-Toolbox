function this = fill(this, newData, newStart, newComment, newUserData)
% fill  Safely replace tseries object properties.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

this.Data = newData;

if nargin>2
    this.Start = newStart(1);
end

this = resetColumnNames(this);
if nargin > 3 
    if iscell(newComment)
        this.Comment(:) = newComment(:);
    elseif ischar(newComment)
        this.Comment(:) = { newComment };
    end
end

if nargin>4
    this = userdata(this, newUserData);
end

this = trim(this);

end
