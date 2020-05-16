function [from, to] = resolveRange(this, varargin)
% resolveRange  Resolve start and end dates of series specific range
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%-------------------------------------------------------------------------- 

if nargin==1
    from = double(this.Start);
    to = double(this.End);
    return
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
    from = this.StartAsNumeric;
end

if isinf(to)
    to = this.EndAsNumeric;
end

end%

