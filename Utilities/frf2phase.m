function [rad, per] = frf2phase(F, varargin)
% frf2phase  Phase shift of frequence response function.
%
% __Syntax__
%
%     [Rad, Per] = frf2phase(F)
%
%
% __Input arguments__
%
% * `F` [ numeric ] - Frequency response matrices computed by `ffrf`.
%
%
% __Output arguments__
%
% * `Rad` [ numeric ] - Phase shift in radians.
%
% * `Per` [ numeric ] - Phase shift in periods.
%
%
% __Options__
%
% See help on `xsf2phase` for options available.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

[rad, per] = xsf2phase(F, varargin{:});

if isa(F, 'namedmat')
    rowNames = rownames(F);
    colNames = colnames(F);
    rad = namedmat(rad, rowNames, colNames);
    if nargin>1 && ~isempty(per)
        per = namedmat(per, rowNames, colNames);
    end
end

end
