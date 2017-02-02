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

if build<20170201
    throw( ...
        exception.Base('Model:CannotLoadFromMat', 'warning'), ...
        '20170130' ...
        ); %#ok<GTARG>
    this = model( ); %#ok<UNRCH>
    return
end

this = populateTransient(this);

end
