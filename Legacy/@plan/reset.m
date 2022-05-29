function This = reset(This)
% endogenise  Remove all endogenized, exogenized, autoexogenized and conditioned upon data points from simulation plan.
%
%
% Syntax
% =======
%
%     P = reset(P)
%
%
% Input arguments
% ================
%
%
% * `P` [ plan ] - Simulation plan.
%
%
% Output arguments
% =================
%
% * `P` [ plan ] - Simulation plan with all endogenized, exogenized,
% autoexogenized and conditioned upon data points removed.
%
%
% Description
% ============
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%#ok<*VUNUS>
%#ok<*CTCH>

%--------------------------------------------------------------------------

This.XAnch(:) = false;
This.NAnchReal(:) = false;
This.NAnchImag(:) = false;
This.CAnch(:) = false;
This.NWghtReal(:) = 0;
This.NWghtImag(:) = 0;
This.AutoX(:) = NaN;

end
