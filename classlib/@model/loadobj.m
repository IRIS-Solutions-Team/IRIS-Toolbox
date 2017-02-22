function this = loadobj(this, varargin)
% loadobj  Prepare model object for loading and handle bkw compatibility.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

MIN_RELEASE = 20170220;

%--------------------------------------------------------------------------

try
    build = sscanf(this.Build, '%g', 1);
catch
    build = 0;
end

if build<MIN_RELEASE
    throw( ...
        exception.Base('Model:CannotLoadFromMat', 'warning'), ...
        sprintf('%i', MIN_RELEASE) ...
        ); %#ok<GTARG>
    this = model( ); %#ok<UNRCH>
    return
end

this = populateTransient(this);

end
