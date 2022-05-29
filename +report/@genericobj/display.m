function display(This)
% disp  Display the structure of a report object.
%
% Help provided in +report/disp.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

textfun.loosespace( );
disp([inputname(1),' =']);
textfun.loosespace( );
disp(This);

end
