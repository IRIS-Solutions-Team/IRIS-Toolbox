function this = replace(this, data, start, comment)
% replace  Safely replace tseries object properties.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

this.data = data;
if nargin>2
    this.start = start(1);
end
requiredSize = size(this.data);
requiredSize = [1, requiredSize(2:end)];
this.Comment = cell(requiredSize);
this.Comment(:) = { '' };
if nargin > 3 
    if iscell(comment)
        this.Comment(:) = comment(:);
    elseif ischar(comment)
        this.Comment(:) = { comment };
    end
end
this = trim(this);

end
