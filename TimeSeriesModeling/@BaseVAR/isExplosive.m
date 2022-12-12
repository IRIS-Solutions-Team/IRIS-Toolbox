% isExplosive  True if any eigenvalue lies outside unit circle
%
% __Syntax__
%
%     flag = isexplosive(v)
%
%
% __Input Arguments__
%
% * `v` [ VAR ] - VAR object whose eigenvalues will be tested for
% instability.
%
%
% __Output Arguments__
%
% * `flag` [ `true` | `false` ] - True if at least one eigenvalue is
% outside unit circle.
%
%
% __Description__
%
%
% __Example__
%


function flag = isExplosive(this)

    flag = any(this.EigenStability==2, 2);
    flag = reshape(flag, 1, [ ]);

end%

