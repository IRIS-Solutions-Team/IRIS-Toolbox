function C = dec2char(This,X)
% dec2char  [Not a public function] Convert numeric position to replacement code.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

X = round(This.Offset + X);

C = sprintf('%g',X);

C = strrep(C,'0',char(16));
C = strrep(C,'1',char(17));
C = strrep(C,'2',char(18));
C = strrep(C,'3',char(19));
C = strrep(C,'4',char(20));
C = strrep(C,'5',char(21));
C = strrep(C,'6',char(22));
C = strrep(C,'7',char(23));
C = strrep(C,'8',char(24));
C = strrep(C,'9',char(25));

end
