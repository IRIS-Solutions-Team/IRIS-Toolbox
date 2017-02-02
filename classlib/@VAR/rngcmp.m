function Flag = rngcmp(V1,V2)
% rngcmp  True if two VAR objects have been estimated using the same dates.
%
% Syntax
% -------
%
%     Flag = rngcmp(V1,V2)
%
% Input arguments
% ================
%
% * `V1`, `V2` [ VAR ] - Two estimated VAR objects.
%
% Output arguments
% =================
% 
% * `Flag` [ `true` | `false` ] - True if the two VAR objects, `V1` and
% `V2`, have been estimated using observations at the same dates.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

pp = inputParser( );
pp.addRequired('V1',@isVAR);
pp.addRequired('V2',@isVAR);
pp.parse(V1,V2);

%--------------------------------------------------------------------------

nAlt1 = size(V1.A,3);
nAlt2 = size(V2.A,3);
nAlt = max(nAlt1,nAlt2);

Flag = false(1,nAlt);
for iAlt = 1 : nAlt
    fitted1 = V1.IxFitted(:,:,min(iAlt,end));
    fitted2 = V2.IxFitted(:,:,min(iAlt,end));
    range1 = V1.Range(fitted1);
    range2 = V2.Range(fitted2);
    Flag(iAlt) = length(range1) == length(range2) ...
        && all(datcmp(range1,range2));
end

end
