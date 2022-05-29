function plot(This,Ax)
% plot  [Not a public function] Draw vline objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(This.location) || ~isnumeric(This.location)
    return
end

grfun.vline(Ax,This.location, ...
    'caption',This.caption, ...
    'vPosition',This.options.vposition, ...
    'hPosition',This.options.hposition, ...
    'timePosition',This.options.timeposition);

end
