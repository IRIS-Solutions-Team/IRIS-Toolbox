function this = populateFromVAR(this, objectVAR)
% populateFromVAR  Populate SVAR properties from VAR superobject
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

metaVAR = metaclass(objectVAR);
for i = 1 : numel(metaVAR.PropertyList)
    p = metaVAR.PropertyList(i);
    if p.Dependent || p.Constant || p.Abstract
        continue
    end
    this.(p.Name) = objectVAR.(p.Name);
end

end%

