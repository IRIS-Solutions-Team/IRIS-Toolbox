% implementGet  Implement set method for iris.mixin.UserDataContainer objects
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function [this, isValidRequest, isValidValue] = implementSet(this, query, value, varargin)

    isintscalar = @(x) isnumeric(x) && isscalar(x) && round(x)==x;
    isValidRequest = true;
    isValidValue = true;

    if any(strcmpi(query, {'BaseYear', 'TOrigin'}))
        isValidValue = isintscalar(value) || isequal(value, @auto);
        if isValidValue
            this.BaseYear = value;
        end
    else
        isValidRequest = false;
    end

end%

