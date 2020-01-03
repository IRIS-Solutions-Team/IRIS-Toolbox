function mainDatabank = horzcat(varargin)
% horzcat  Horizontally concatenate fields of two or more databanks
%
% __Syntax__
%
%     D = databank.horzcat(D, D1, ...)
%
%
% __Input Arguments__
%
% * `D` [ struct ] - Databank that will be merged with the other input
% databanks, `D1`, etc. using the method specified by `Method`.
%
% * `D1` [ struct ] - One or more databanks with which the input databank
% `D` will be concatenated.
%
%
% __Output Arguments__
%
% * `D` [ struct ] - Output databank whose fields are created by
% horizontally concatenating the fiels of the input databanks.
%
%
% __Options__
%
% * `MissingField=@rmfield` [ `@rmfield` | `NaN` | * ] - What to do when a
% field is missing from one or more of the input databanks.
%
%
% __Description__
%
%
% __Example__
%
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

mainDatabank = databank.merge('horzcat', varargin{:});

end%
