function varargout = findlast(varargin)
% findlast  Find last nonzero or true value in 2nd dimension.
%
% Syntax
% =======
%
%     Pos = utils.findlast(X);
%
%
% Input arguments
% ================
%
% * `X` [ logical | numeric ] - A logical or numeric matrix
% (3-dimensional at most).
%
%
% Output arguments
% =================
%
% * `Pos` [ numeric ] - The 2nd-dimension position of the last `true` or
% last non-zero value in any row or any page of `X`; returns `0` if non
% `true` or non-zero value exists.
%
%
% Description
% ============
%
% If `X` is a numeric array, all `NaN` values are first reset to zero
% before looking up the position of the last non-zero value.
%
%
% Example
% ========
%
% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

n = max(nargin, nargout);
varargout = cell(1, n);
varargout(:) = { 0 };

for i = 1 : n
    X = varargin{i};
    if isempty(X)
        continue
    end 
    if ~islogical(X)
        X(isnan(X)) = 0;
        X = X ~= 0;
    end
    varargout{i} = max([ 0, find(any(any(X, 3), 1), 1, 'last') ]);
end

end
