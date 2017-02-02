function Dat = ddtoday( )
% ddtoday  Matlab serial date number for today's date.
%
% Syntax
% =======
%
%     Dat = ddtoday( )
%
% Output arguments
% =================
%
% * `Dat` [ numeric ]  - Matlab serial date number for today's date.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

Dat = floor(now( ));

end
