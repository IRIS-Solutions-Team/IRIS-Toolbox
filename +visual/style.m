function style(handles, specs, varargin)
% visual.style  Style graphics objects

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('visual.style');
    inputParser.addRequired('Handle', @(x) isempty(x) || all(isgraphics(x)));
    inputParser.addRequired('Specs', @isstruct);
    inputParser.addParameter('StyleChildren', true, @(x) isequal(x, true) || isequal(x, false));
end
inputParser.parse(handles, specs, varargin{:});
opt = inputParser.Options;

if isempty(handles)
    return
end

%--------------------------------------------------------------------------

numHandles = numel(handles);
specsTypes = fieldnames(specs);
errors = cell.empty(0, 1);
for i = 1 : numHandles
    ithHandle = handles(i);
    handleVisible = get(ithHandle, 'HandleVisibility');
    if ~strcmpi(handleVisible, 'On')
        continue
    end
    ithType = get(ithHandle, 'Type');
    indexMatchType = strcmpi(specsTypes, ithType);
    if any(indexMatchType)
        pos = find(indexMatchType, 1);
        errors = apply(ithHandle, ithType, specs.(specsTypes{pos}), i, errors);
    end
    if ~isequal(opt.StyleChildren, true)
        continue
    end
    children = get(ithHandle, 'Children');
    visual.style(children, specs, varargin{:});
end

if ~isempty(errors)
    errors = unique(errors);
    disp(errors)
end
end%


function errors = apply(handle, type, specs, i, errors)
    errors = extra('PreStyle', handle, type, specs, i, errors); 
    propertyNames = fieldnames(specs);
    numProperties = numel(propertyNames);
    for i = 1 : numProperties
        ithPropertyName = propertyNames{i};
        if any(strcmpi(ithPropertyName, {'PreStyle', 'PostStyle'}))
            continue
        end
        ithPropertyValue = specs.(ithPropertyName);
        try
            set(handle, ithPropertyName, ithPropertyValue);
        catch
            errors{end+1, 1} = sprintf('%s.%s', type, ithPropertyName);
        end
    end
    errors = extra('PostStyle', handle, type, specs, i, errors); 
end%


function errors = extra(which, handle, type, specs, i, errors)
    propertyNames = fieldnames(specs);
    index = strcmpi(propertyNames, which);
    if ~any(index)
        return
    end
    pos = find(index, 1);
    func = specs.(propertyNames{pos});
    if ~iscell(func)
        func = { func };
    end
    numFunc = numel(func);
    for i = 1 : numFunc
        ithFunc = func{i};
        if ~isa(ithFunc, 'function_handle')
            continue 
        end
        try
            ithFunc(handle);
        catch
            errors{end+1, 1} = sprintf('%s.%s', type, which);
        end
    end
end%

