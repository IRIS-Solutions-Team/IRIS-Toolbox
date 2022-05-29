function loosespace( )
% loosespace  Print a line break if spacing is set to loose.
%
% Syntax
% =======
%
%     textfun.loosespace( )
%
% Description
% ============
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

if ~strcmp(get(0, 'FormatSpacing'), 'compact')
   fprintf('\n');
end

end
