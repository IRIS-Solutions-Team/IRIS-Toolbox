function [from, to] = resolveRange(this, from, to)
% resolveRange  Resolve start and end dates of series specific range
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%-------------------------------------------------------------------------- 

if nargin==1
    from = double(this.Start);
    to = double(this.End);
    return
end

if nargin==2
    to = from;
end

from = double(from);
to = double(to);

if isinf(from)
    from = double(this.Start);
end

if isinf(to)
    to = double(this.End);
end

end%
