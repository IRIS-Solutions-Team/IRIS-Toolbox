function msg = removeTags(msg)
% removeTags  Remove HTML tags from message before printing.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

msg = regexprep(msg, '<a[^<]*>', '');
msg = strrep(msg, '</a>', '');
msg = strrep(msg, '<strong>', '');
msg = strrep(msg, '</strong>', '');

end
