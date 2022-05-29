function C = shortclass(This)
% shortclass  [Not a public function] Short class name of report objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

C = class(This);
C = strrep(C,'report.','');
C = strrep(C,'obj','');

end
