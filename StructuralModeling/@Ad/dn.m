% dn  Compute numerical derivatives of non-analytical or user-defined functions
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function df = dn(func, k, varargin)

if numel(k)==1
    % First derivative
    df = locallyNumDiff(func, k, varargin{:});

elseif numel(k)==2
    % Second derivative; these are needed in optimal policy models with
    % user-supplied functions
    y0 = varargin{k(2)};
    hy = abs(eps( )^(1/3.5))*max([y0, 1]);
    yp = y0 + hy;
    ym = y0 - hy;
    varargin{k(2)} = yp;
    fp = locallyNumDiff(func, k(1), varargin{:});
    varargin{k(2)} = ym;
    fm = locallyNumDiff(func, k(1), varargin{:});
    df = (fp - fm) ./ (yp - ym);

end

end%

function df = locallyNumDiff(func, k, varargin)
    % epsilon = eps( )^(1/3.5);
    epsilon = eps( )^(1/3);
    x0 = varargin{k};
    hx = epsilon*max(abs(x0), 1);
    xp = x0 + hx;
    xm = x0 - hx;
    varargin{k} = xp;
    fp = feval(func, varargin{:});
    varargin{k} = xm;
    fm = feval(func, varargin{:});
    df = (fp - fm) ./ (xp - xm);
end%

