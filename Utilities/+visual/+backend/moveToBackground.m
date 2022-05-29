% moveToBackground  Reorder selected graphics objects in the background
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function moveToBackground(axesHandles)

if isempty(axesHandles)
    return
end

numAxesHandles = numel(axesHandles);
for i = 1 : numAxesHandles
    %children = allchild(axesHandles(i));
    children = get(axesHandles(i), 'Children');
    numChildren = numel(children);
    level = zeros(1, numChildren);
    for j = 1 : numChildren
        ithLevel = getappdata(children(j), 'IRIS_BackgroundLevel');
        if validate.numericScalar(ithLevel) && ithLevel<0
            level(j) = ithLevel;
        end
    end
    inxBackgroundChildren = level<0;
    foregroundChildren = children(~inxBackgroundChildren);
    backgroundChildren = children(inxBackgroundChildren);
    levelBackgroundChildren = level(inxBackgroundChildren);
    [~, permuted] = sort(levelBackgroundChildren, 'Descend');
    backgroundChildren = backgroundChildren(permuted);
    children = [foregroundChildren; backgroundChildren];
    set(axesHandles(i), 'Children', children);
end

end%

