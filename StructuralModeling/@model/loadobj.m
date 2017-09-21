function this = loadobj(this, varargin)
% loadobj  Prepare model object for loading and handle bkw compatibility.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

try
    build = sscanf(this.Build, '%g', 1);
catch
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
