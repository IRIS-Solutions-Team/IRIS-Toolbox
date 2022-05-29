function X = char2dec(This,C)
% char2dec  [Not a public function] Convert replacement code to numeric.
%
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

C = strrep(C,This.OpenChar,'');
C = strrep(C,This.CloseChar,'');

C = strrep(C,char(16),'0');
C = strrep(C,char(17),'1');
C = strrep(C,char(18),'2');
C = strrep(C,char(19),'3');
C = strrep(C,char(20),'4');
C = strrep(C,char(21),'5');
C = strrep(C,char(22),'6');
C = strrep(C,char(23),'7');
C = strrep(C,char(24),'8');
C = strrep(C,char(25),'9');
if iscellstr(C)
    C = sprintf('%s ',C{:});
end
X = sscanf(C,'%d');
X = round(X);
X = X(:).';

end
