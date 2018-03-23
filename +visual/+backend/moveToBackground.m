function moveToBackground(axesHandles)
% moveToBackground  Reorder selected graphics objects in the background
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

if isempty(axesHandles)
    return
end

%--------------------------------------------------------------------------

numAxesHandles = numel(axesHandles);
for i = 1 : numAxesHandles
    children = get(axesHandles(i), 'children');
    numChildren = numel(children);
    level = zeros(1, numChildren);
    for j = 1 : numChildren
        ithLevel = getappdata(children(j), 'IRIS_BackgroundLevel');
        if ~isempty(ithLevel) && isnumeric(ithLevel) && isscalar(ithLevel) && ithLevel<0
            level(j) = ithLevel;
        end
    end
    [~, permuted] = sort(level, 'descend');
    set(axesHandles(i), 'children', children(permuted));
end

end
