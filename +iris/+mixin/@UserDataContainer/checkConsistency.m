function flag = checkConsistency(this)
% checkConsistency  Check internal consistency of object properties
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

flag = ischar(this.Caption) ...
       && (isequal(this.BaseYear, @auto) || isnumeric(this.BaseYear));

end%

