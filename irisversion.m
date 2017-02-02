function [C,N] = irisversion( )
% irisversion  Current IRIS version.
%
%
% Syntax
% =======
%
%     irisversion
%     X = irisversion( )
%
%
% Output arguments
% =================
%
% * `X` [ char ] - String describing the currently installed IRIS version.
%
%
% Description
% ============
%
% The version string is the distribution date in a `yyyymmdd` format. The
% `irisversion` function is equivalent to the call `irisget('version')`.
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

% IRIS version is permanently stored in the root Contents.m file, and is
% accessible through the Matlab ver( ) command. In each session, the version
% is refreshed by the `irisconfig` file.

C = irisconfigmaster('get','version');
if nargout > 1
    N = sscanf(C,'%g',1);
end

end
