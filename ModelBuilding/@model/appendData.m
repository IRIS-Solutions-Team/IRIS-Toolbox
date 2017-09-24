function outp = appendData(inp, outp, range, opt)
% appendData  Execute DbOverlay= or AppendPresample= options.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isequal(opt.dboverlay, false) && isequal(opt.AppendPresample, false)
    return
end
% Overlay the input (or user-supplied) database with the simulation
% database.
if isequal(opt.dboverlay, true)
    outp = dboverlay(inp, outp);
    return
elseif isstruct(opt.dboverlay)
    outp = dboverlay(opt.dboverlay, outp);
    return
elseif isequal(opt.AppendPresample, true)
    outp = dboverlay( ...
        dbclip(inp, [-Inf, range(1)-1]), ...
        outp ...
        );
    return
elseif isstruct(opt.AppendPresample)
    outp = dboverlay( ...
        dbclip(opt.AppendPresample, [-Inf, range(1)-1]), ...
        outp ...
        );
    return
end

end
