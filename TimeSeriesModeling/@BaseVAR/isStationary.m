% isStationary  True if all eigenvalues lie within unit circle
%
% __Syntax__
%
%     flag = isStationary(V)
%
%
% __Input Arguments__
%
% * `V` [ VAR ] - VAR object whose eigenvalues will be tested for
% stationarity.
%
%
% __Output Arguments__
%
% * `flag` [ `true` | `false` ] - True if all eigenvalues are within unit
% circle.
%
%
% __Description__
%
%
% __Example__
%

function flag = isStationary(this)

    flag = all(this.EigenStability==0, 2);
    flag = reshape(flag, 1, []);

end%

