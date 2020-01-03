function df = d(func, k, varargin)
% d  Compute user-supplied derivatives of non-analytic functions or force numeric derivatives
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

% Test if the user function returns derivatives
%
%     func(x, y, z, 'diff')
%
% This call to `func` must produce `true`.
%
% Get a user-supplied first derivative by calling the function itself with
% a 'diff' argument. For example, 
%
%     func(x, y, z, 'diff', 3)
%
% expects the first derivative of the function w.r.t. the 3-rd input
% argument.

try
    test = feval(func, varargin{:}, 'diff');
    isUserDiff = isequal(test, true);
catch %#ok<CTCH>
    isUserDiff = false;
end

%
% Capture the user-supplied derivative
%
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

df = Ad.dn(func, k, varargin{:});

end%

