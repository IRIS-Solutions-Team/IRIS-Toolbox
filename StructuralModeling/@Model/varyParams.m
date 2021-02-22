function overrideParams = varyParams(this, baseRange, override)
% varyParams  Create array of user-supplied time-varying values for regular parameters
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

TYPE = @int8;

%--------------------------------------------------------------------------

inxP = getIndexByType(this.Quantity, TYPE(4));
requiredNames = string.empty(1, 0);
optionalNames = this.Quantity.Name(inxP);
namesAllowedScalar = @all;

if isempty(intersect(fieldnames(override), optionalNames))
    overrideParams = [ ];
    return
end

dbInfo = checkInputDatabank( ...
    this, override, baseRange ...
    , requiredNames, optionalNames ...
    , namesAllowedScalar ...
);

overrideParams = requestData(this, dbInfo, override, baseRange, optionalNames);
overrideParams = numeric.removeTrailingNaNs(overrideParams, 2);

end%
