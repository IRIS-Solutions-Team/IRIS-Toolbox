function c = chkStd(c)
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

TOLERANCE = eps( );

%--------------------------------------------------------------------------

if not( norm(triu(c)-c)<TOLERANCE )
    % Compute square root matrix using Cholesky
    c = chol(c);
end

end
