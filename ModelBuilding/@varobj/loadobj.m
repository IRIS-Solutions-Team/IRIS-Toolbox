function this = loadobj(this)
% loadobj  Prepare varobj based objects for loading and handle bkw compatibility.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

try
    build = sscanf(this.Build,'%g',1);
catch
    build = 0;
end

if build<20150218
    this.IxFitted = this.Fitted;
    this = rmfield(this, 'Fitted');
end

if isstruct(this)
    this = struct2obj(this);
end

end
