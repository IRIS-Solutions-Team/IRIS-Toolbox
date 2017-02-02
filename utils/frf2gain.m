function F = frf2gain(F,varargin)
% frf2gain  Gain of frequency response function.
%
% Syntax
% =======
%
%     G = frf2gain(F)
%
% Input arguments
% ================
%
% * `F` [ numeric ] - Frequency response function.
%
% Output arguments
% =================
%
% * `G` [ numeric ] - Gain of frequency response function.
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

isNamed = isnamedmat(F);

if isNamed
    rowNames = rownames(F);
    colNames = colnames(F);
end
    
F = abs(F);

if isNamed
    F = namedmat(F,rowNames,colNames);
end

end
