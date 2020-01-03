function df = dn(func, k, varargin)
% dn  Compute numerical derivatives of non-analytical or user-defined functions
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

if length(k)==1
    % First derivative
    df = hereNumDiff(func, k, varargin{:});
    return
elseif length(k)==2
    % Second derivative; these are needed in optimal policy models with
    % user-supplied functions
    y0 = varargin{k(2)};
    hy = abs(eps( )^(1/3.5))*max([y0, 1]);
    yp = y0 + hy;
    ym = y0 - hy;
    varargin{k(2)} = yp;
    fp = hereNumDiff(func, k(1), varargin{:});
    varargin{k(2)} = ym;
    fm = hereNumDiff(func, k(1), varargin{:});
    df = (fp - fm) / (yp - ym);
end

return

    function df = hereNumDiff(func, k, varargin)
        epsilon = eps( )^(1/3.5);
        x0 = varargin{k};
        hx = abs( epsilon*max(x0, 1) );
        xp = x0 + hx;
        xm = x0 - hx;
        varargin{k} = xp;
        fp = feval(func, varargin{:});
        varargin{k} = xm;
        fm = feval(func, varargin{:});
        df = (fp - fm) ./ (xp - xm);
    end%
end%
