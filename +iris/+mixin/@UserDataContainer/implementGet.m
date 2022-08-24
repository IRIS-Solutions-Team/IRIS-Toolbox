function [answ, flag, query] = implementGet(this, query, varargin)
% implementGet  Implement get method for iris.mixin.UserDataContainer objects
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

answ = [ ];
flag = true;
if any(strcmpi(query, {'BaseYear', 'TOrigin'}))
    answ = this.BaseYear;
    if isequal(answ, @auto) || isempty(answ)
        answ = iris.get('BaseYear');
    end
else
    flag = false;
end

end%

