function [ep, wp] = errorparsing(this)
% errorparsing  Create "Error parsing" and "Warning parsing" messages.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

fname = implementGet(this, 'file');

if true % ##### MOSW
    p = sprintf('parsing file(s) <a href="matlab: edit %s">%s</a>. ', ...
        strrep(fname,' & ',' '), fname);
else
    p = sprintf('parsing file(s) %s. ', fname); %#ok<UNRCH>
end

ep = ['Error ', p];
wp = ['Warning ', p];

end
