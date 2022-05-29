function G = frf2gain(F, varargin)
% frf2gain  Gain of frequency response function
%
% __Syntax__
%
%     G = frf2gain(F)
%
%
% __Input arguments__
%
% * `F` [ numeric ] - Frequency response function.
%
%
% __Output arguments__
%
% * `G` [ numeric ] - Gain of frequency response function.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------
    
G = abs(F);

if isa(F, 'namedmat')
    rowNames = rownames(F);
    colNames = colnames(F);
    G = namedmat(G, rowNames, colNames);
end

end%

