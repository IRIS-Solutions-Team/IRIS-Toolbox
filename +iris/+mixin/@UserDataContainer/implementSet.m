function [this, isValidRequest, isValidValue] = implementSet(this, query, value, varargin)
% implementGet  Implement set method for iris.mixin.UserDataContainer objects
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

isValidRequest = true;
isValidValue = true;

if any(strcmpi(query, {'BaseYear', 'TOrigin'}))
    isValidValue = isintscalar(value) || isequal(value, @config);
    if isValidValue
        this.BaseYear = value;
    end
else
    isValidRequest = false;
end

end%

