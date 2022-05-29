% loadobj  Prepare model object for loading and handle bkw compatibility
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function this = loadobj(this, varargin)

build = [ ];
try
    build = sscanf(this.Build, '%g', 1);
end
if ~isnumeric(build) || ~isscalar(build)
    build = 0;
end

if ~isa(this, 'model') || build<model.LAST_LOADABLE
    throw( ...
        exception.Base('Model:CannotLoadFromMat', 'warning'), ...
        sprintf('%i', model.LAST_LOADABLE) ...
    ); 
    loadObjectAsStruct = this;
    this = model( ); 
    this.LoadObjectAsStruct = loadObjectAsStruct;
    return
end

this = populateTransient(this);

end%

