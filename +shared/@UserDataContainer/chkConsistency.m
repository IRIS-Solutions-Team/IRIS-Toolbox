function flag = chkConsistency(this)
% chkConsistency  Check internal consistency of object properties.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

flag = (ischar(this.Comment) || iscellstr(this.Comment)) && ...
    ischar(this.Caption) && ...
    (isequal(this.BaseYear, @config) || isnumeric(this.BaseYear));

end

