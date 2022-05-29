function flag = islog(this, lsName)
% islog  True for log-linearised variables.
%
% Syntax
% =======
%
%     Flag = islog(M,Name)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object.
%
% * `Name` [ char | cellstr ] - Name or names of model variable(s).
%
% Output arguments
% =================
%
% * `Flag` [ `true` | `false` ] - True for log variables.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

pp = inputParser( );
pp.addRequired('Name', @(x) ischar(x) || iscellstr(x) || isstring(x));
pp.parse(lsName);

if ischar(lsName)
    lsName = regexp(lsName, '\w+', 'match');
end

%--------------------------------------------------------------------------

flag = false(size(lsName));
ixValid = true(size(lsName));
for i = 1 : length(lsName)
    ix = strcmp(this.Quantity.Name, lsName{i});
    if any(ix)
        flag(i) = this.Quantity.IxLog(ix);
    else
        ixValid(i) = false;
    end
end

if any(~ixValid)
    utils.error('model:islog', ...
        ['This name does not exist ', ...
        'in the model object: ''%s''.'], ...
        lsName{~ixValid});
end

end
