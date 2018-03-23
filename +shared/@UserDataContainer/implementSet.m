function [this, isValidRequest, isValidValue] = implementSet(this, query, value, varargin)
% implementGet  Implement set method for shared.UserDataContainer objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

isValidRequest = true;
isValidValue = true;

switch lower(query)
    case {'baseyear', 'torigin'}
        isValidValue = isintscalar(value) || isequal(value, @config);
        if isValidValue
            this.BaseYear = value;
        end
        
        
        
        
    otherwise
        isValidRequest = false;
end

end
