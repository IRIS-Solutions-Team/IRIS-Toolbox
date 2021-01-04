% resolveRange  Resolve start and end dates of series specific range
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

function [from, to, range] = resolveRange(this, varargin)

if nargin==1
    from = double(this.Start);
    to = this.EndAsNumeric;
    return
end

if strcmp(varargin{1}, ":") || isequal(varargin{1}, @all)
    varargin{1} = Inf;
end

varargin{1} = double(varargin{1});
from = varargin{1}(1);
if nargin>=3
    varargin{2} = double(varargin{2});
    to = varargin{2}(end);
else
    to = varargin{1}(end);
end

if isinf(from)
    from = double(this.Start);
end

if isinf(to)
    to = this.EndAsNumeric;
end

if nargout>=3
    if isnan(from) && isnan(to)
        range = double.empty(0, 1);
        return
    end
    range = dater.colon(from, to);
end

end%

