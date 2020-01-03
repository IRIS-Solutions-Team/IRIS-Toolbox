function [this, isValidRequest, isValidValue] = implementSet(this, query, value, varargin)
% implementGet  Implement set method for shared.UserDataContainer objects
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

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

