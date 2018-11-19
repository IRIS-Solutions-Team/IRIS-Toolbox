function style(handles, specs, varargin)
% visual.style  Style graphics objects

persistent parser
if isempty(parser)
    parser = extend.InputParser('visual.style');
    parser.addRequired('Handle', @(x) isempty(x) || all(isgraphics(x)));
    parser.addRequired('Specs', @isstruct);
    parser.addParameter('StyleChildren', true, @(x) isequal(x, true) || isequal(x, false));
end
parser.parse(handles, specs, varargin{:});
opt = parser.Options;

if isempty(handles)
    return
end

%--------------------------------------------------------------------------

numOfHandles = numel(handles);
specsTypes = fieldnames(specs);
errors = cell.empty(0, 1);
count = struct( );
for i = numOfHandles : -1 : 1
    ithHandle = handles(i);
    handleVisible = get(ithHandle, 'HandleVisibility');
    if ~strcmpi(handleVisible, 'On')
        continue
    end
    ithType = get(ithHandle, 'Type');
    if isfield(count, ithType)
        count.(ithType) = count.(ithType) + 1;
    else
        count.(ithType) = 1;
    end
    indexMatchType = strcmpi(specsTypes, ithType);
    if any(indexMatchType)
        pos = find(indexMatchType, 1);
        errors = apply(ithHandle, ithType, specs.(specsTypes{pos}), count.(ithType), errors);
    end
    if ~isequal(opt.StyleChildren, true)
        continue
    end
    children = get(ithHandle, 'Children');
    visual.style(children, specs, varargin{:});
end

if ~isempty(errors)
    errors = unique(errors);
    % disp(errors)
end
end%


function errors = apply(handle, type, specs, j, errors)
    persistent listOfExtras
    if isempty(listOfExtras)
        listOfExtras = { 'Line.ShowValues', 'showValues' 
                         'Bar.ShowValues',  'showValues' };
    end

    errors = runPreAndPost('Prestyle', handle, type, specs, j, errors); 
    propertyNames = fieldnames(specs);
    numOfProperties = numel(propertyNames);
    for i = 1 : numOfProperties
        ithPropertyName = propertyNames{i};
        if any(strcmpi(ithPropertyName, {'Prestyle', 'Poststyle'}))
            continue
        end
        ithPropertyValue = specs.(ithPropertyName);
        if iscell(ithPropertyValue)
            assignValue = ithPropertyValue{min(j, end)};
        else
            assignValue = ithPropertyValue;
        end
        try
            currentValue = get(handle, ithPropertyName);
            if isgraphics(currentValue)
                errors = apply(currentValue, ithPropertyName, assignValue, j, errors);
                continue
            end
        end
        index = strcmpi([type, '.', ithPropertyName], listOfExtras(:, 1));
        try
            if any(index)
                extraFunctionName = listOfExtras{index, 2};
                feval(extraFunctionName, handle, ithPropertyValue);
            else
                set(handle, ithPropertyName, assignValue);
            end
        catch
            errors{end+1, 1} = sprintf('%s.%s', type, ithPropertyName);
        end
    end
    errors = runPreAndPost('Poststyle', handle, type, specs, j, errors); 
end%


function errors = runPreAndPost(which, handle, type, specs, i, errors)
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
        ithFunc = func{i}(handle);
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


function showValues(handle, ithPropertyValue)
    if isequal(ithPropertyValue, false)
        return
    end
    if isequal(ithPropertyValue, true)
        ithPropertyValue = cell.empty(1, 0);
    end
    visual.values(handle, ithPropertyValue{:});
end%

