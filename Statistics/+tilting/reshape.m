function [x, r] = reshape(x, varargin)
% tilting.reshape  Requested dimension into 1D and unfold higher dimensions into 2D.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

if nargin>2
    dim = varargin{1};
    maxDim = varargin{2};
    p = 1 : max(ndims(x), dim);
    if dim>1
        p(dim) = [ ];
        p = [dim, p];
        x = permute(x, p);
    end
    s = size(x);
    if numel(s)>maxDim
        temp = repmat({':'}, 1, maxDim);
        x = x(temp{:});
    end
    r = struct( );
    r.Dim = dim;
    r.MaxDim = maxDim;
    r.Permute = p;
    r.Size = s;
else
    r = varargin{1};
    dim = r.Dim;
    maxDim = r.MaxDim;
    p = r.Permute;
    s = r.Size;
    if numel(s)>maxDim
        s(1) = size(x, 1);
        x = reshape(x, s);
    end
    if dim>1
        x = ipermute(x, p);
    end
end

end

