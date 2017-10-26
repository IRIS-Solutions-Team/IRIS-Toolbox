function moveToBackground(axesHandles)
% moveToBackground  Reorder selected graphics objects in the background
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

if isempty(axesHandles)
    return
end

numAxesHandles = length(axesHandles);
if numAxesHandles>1
    for i = 1 : numAxesHandles
        grfun.mymovetobkg(axesHandles(i));
    end
    return
end

%--------------------------------------------------------------------------

children = get(axesHandles, 'children');
numChildren = numel(children);
level = zeros(1, numChildren);
for i = 1 : numChildren
    ithLevel = getappdata(children(i), 'IRIS_BackgroundLevel');
    if ~isempty(ithLevel) && isnumeric(ithLevel) && isscalar(ithLevel) && ithLevel<0
        level(i) = ithLevel;
    end
end
[~, permuted] = sort(level, 'descend');
set(axesHandles, 'children', children(permuted));

end
