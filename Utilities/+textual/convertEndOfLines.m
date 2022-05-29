function x = convertEndOfLines(x)
% convertEndOfLines  Convert all types of EOLs to \n
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

x = replace(x, sprintf('\r\n'), sprintf('\n'));
x = replace(x, sprintf('\r'), sprintf('\n'));

end%

