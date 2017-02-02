function plot(This,Ax)
% plot  [Not a public function] Draw highlight objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

x = This.location;

if isempty(This.location) ...
        || ~(isnumeric(x) || (iscell(x) && all(cellfun(@isnumeric,x))))
    return
end

grfun.highlight(Ax,This.location, ...
    'caption',This.caption, ...
    'vPosition',This.options.vposition, ...
    'hPosition',This.options.hposition);

end