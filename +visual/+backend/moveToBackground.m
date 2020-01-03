function moveToBackground(axesHandles)
% moveToBackground  Reorder selected graphics objects in the background
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

if isempty(axesHandles)
    return
end

%--------------------------------------------------------------------------

numAxesHandles = numel(axesHandles);
for i = 1 : numAxesHandles
    %children = allchild(axesHandles(i));
    children = get(axesHandles(i), 'Children');
    numOfChildren = numel(children);
    level = zeros(1, numOfChildren);
    for j = 1 : numOfChildren
        ithLevel = getappdata(children(j), 'IRIS_BackgroundLevel');
        if validate.numericScalar(ithLevel) && ithLevel<0
            level(j) = ithLevel;
        end
    end
    inxOfBackgroundChildren = level<0;
    foregroundChildren = children(~inxOfBackgroundChildren);
    backgroundChildren = children(inxOfBackgroundChildren);
    levelOfBackgroundChildren = level(inxOfBackgroundChildren);
    [~, permuted] = sort(levelOfBackgroundChildren, 'Descend');
    backgroundChildren = backgroundChildren(permuted);
    children = [foregroundChildren; backgroundChildren];
    set(axesHandles(i), 'Children', children);
end

end%

