function [answ, flag, query] = implementGet(this, query, varargin)
% implementGet  Implement get method for shared.UserDataContainer objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

answ = [ ];
flag = true;

switch lower(query)
    case {'baseyear', 'torigin'}
        answ = this.BaseYear;
        if isequal(answ, @config) || isempty(answ)
            answ = iris.get('BaseYear');
        end
        
        
        
    otherwise
        flag = false;
end

end
