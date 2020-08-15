function this = loadobj(this, varargin)
% loadobj  Prepare model object for loading and handle bkw compatibility.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%--------------------------------------------------------------------------

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

end
