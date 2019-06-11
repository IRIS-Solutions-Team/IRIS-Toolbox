function [c, n] = version( )
% iris.version  Current IRIS version
%
% __Syntax__
%
%     iris.version
%     V = iris.version( )
%
%
% __Output Arguments__
%
% * `V` [ char ] - String describing the currently installed IRIS version.
%
%
% __Description__
%
% The version string is the distribution date in a `yyyymmdd` format. The
% `iris.version` function is equivalent to calling `iris.get('Version')`.
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

% IRIS version is permanently stored in the root Contents.m file, and is
% accessible through the Matlab ver( ) command. In each session, the
% version is refreshed by `iris.Configuration( )`.

c = iris.get('Version');
if nargout>1
    n = sscanf(c, '%g', 1);
end

end%

