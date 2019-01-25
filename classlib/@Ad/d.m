function df = d(func, k, varargin)
% d  Compute numerical derivatives of non-analytical or user-defined functions.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

% Test if the user function returns derivatives
%
%     func(x,y,z,'diff')
%
% This call to `func` must produce `true`.
%
% Get a user-supplied first derivative by calling the function itself with
% a 'diff' argument. For example,
%
%     func(x,y,z,'diff',3)
%
% expects the first derivative of the function w.r.t. the 3-rd input
% argument.

try
    test = feval(func, varargin{:}, 'diff');
    isUserDiff = isequal(test, true);
catch %#ok<CTCH>
    isUserDiff = false;
end

% Capture the user-supplied derivative
%--------------------------------------
nd = length(varargin{k(end)});
if isUserDiff
    status = warning( );
    warning('off');
    try
        % User-supplied derivatives.
        df = feval(func, varargin{:}, 'diff', k);
        if ~isnumeric(df) || length(df)~=nd
            df = NaN;
        end
    catch %#ok<CTCH>
        df = NaN;
    end
    warning(status);
    if isfinite(df)
        return
    end
end

% Compute the derivative numerically
%------------------------------------
if length(k)==1
    % First derivative.
    df = numdiff(func, k, varargin{:});
    return
elseif length(k)==2
    % Second derivative; these are needed in optimal policy models with
    % user-supplied functions.
    y0 = varargin{k(2)};
    hy = abs(eps( )^(1/3.5))*max([y0, 1]);
    yp = y0 + hy;
    ym = y0 - hy;
    varargin{k(2)} = yp;
    fp = numdiff(func, k(1), varargin{:});
    varargin{k(2)} = ym;
    fm = numdiff(func, k(1), varargin{:});
    df = (fp - fm) / (yp - ym);
end

return




    function df = numdiff(func, k, varargin)
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
    end
end
