function [N,NReal,NImag] = nnzendog(This)
% nnzendog  Number of endogenised data points.
%
%
% Syntax
% =======
%
%     [N,NReal,NImag] = nnzendog(P)
%
%
% Input arguments
% ================
%
% * `P` [ plan ] - Simulation plan.
%
%
% Output arguments
% =================
%
% * `N` [ numeric ] - Total number of endogenised data points; each shock
% at each time counts as one data point.
%
% * `NRea,` [ numeric ] - Number of endogenised data points with
% anticipation mode 1.
%
% * `NImag` [ numeric ] - Number of endogenised data points with
% anticipation mode 1i.
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

%--------------------------------------------------------------------------

NReal = nnz(This.NAnchReal);
NImag = nnz(This.NAnchImag); 
N = NReal + NImag;

end
