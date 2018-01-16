function outp = appendData(this, inp, outp, range, opt)
% appendData  Execute DbOverlay= or AppendPresample= options
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isequal(opt.DbOverlay, false) && isequal(opt.AppendPresample, false)
    return
end

% Append only names already included in output databank
inpFields = fieldnames(inp);
outpFields = fieldnames(outp);
inp = rmfield(inp, setdiff(inpFields, outpFields));

% Overlay the input (or user-supplied) database with the simulation
% database.
if isequal(opt.DbOverlay, true)
    outp = dboverlay(inp, outp);
    return
elseif isstruct(opt.DbOverlay)
    outp = dboverlay(opt.DbOverlay, outp);
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
