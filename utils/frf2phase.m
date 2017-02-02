function [Rad,Per] = frf2phase(F,varargin)
% frf2phase  Phase shift of frequence response function.
%
% Syntax
% =======
%
%     [Rad,Per] = frf2phase(F)
%
% Input arguments
% ================
%
% * `F` [ numeric ] - Frequency response matrices computed by `ffrf`.
%
% Output arguments
% =================
%
% * `Rad` [ numeric ] - Phase shift in radians.
%
% * `Per` [ numeric ] - Phase shift in periods.
%
% Options
% ========
%
% See help on `xsf2phase` for options available.
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

[Rad,Per] = xsf2phase(F,varargin{:});

if isNamed
    Rad = namedmat(Rad,rowNames,colNames);
    if nargin > 1 && ~isempty(Per)
        Per = namedmat(Per,rowNames,colNames);
    end
end

end
