% visual.style  Style graphics objects

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function style(handles, specs, varargin)

BACKGROUND = [ 
    "Highlight"
    "VLine"
    "HLine"
    "ZeroLine"
];

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('visual.style');
    pp.addRequired('Handle', @(x) isempty(x) || all(isgraphics(x)));
    pp.addRequired('Specs', @isstruct);
    pp.addParameter('Children', true, @(x) isequal(x, true) || isequal(x, false));
end
%)
opt = pp.parse(handles, specs, varargin{:});

if isempty(handles)
    return
end

%--------------------------------------------------------------------------

numHandles = numel(handles);
specsTypes = fieldnames(specs);
errors = cell.empty(0, 1);
count = struct( );
for i = numHandles : -1 : 1
    ithHandle = handles(i);
    handleVisible = get(ithHandle, 'HandleVisibility');
    if ~strcmpi(handleVisible, 'On')
        continue
    end
    ithTag = get(ithHandle, 'Tag');
    ithType = get(ithHandle, 'Type');
    if any(strcmpi(ithTag, BACKGROUND)) && any(strcmpi(ithTag, specsTypes))
        if ~isfield(count, ithTag)
            count.(ithTag) = 1;
        end
        % Apply style to background objects: highligh, vline, hline, zeroline
        pos = find(strcmpi(ithTag, specsTypes));
        testLevel = false;
        [errors, addCount] = apply(ithHandle, ithType, specs.(specsTypes{pos}), count.(ithTag), errors, testLevel);
        count.(ithTag) = count.(ithTag) + addCount;
    else
        if ~isfield(count, ithType)
            count.(ithType) = 1;
        end
        inxMatchType = strcmpi(specsTypes, ithType);
        if any(inxMatchType)
            pos = find(inxMatchType, 1);
            testLevel = true;
            [errors, addCount] = apply(ithHandle, ithType, specs.(specsTypes{pos}), count.(ithType), errors, testLevel);
            count.(ithType) = count.(ithType) + addCount;
        end
    end
    if ~isequal(opt.Children, true)
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


%
% Local Functions
%


function [errors, addCount] = apply(handle, type, specs, j, errors, testLevel)
    persistent listOfExtras
    if isempty(listOfExtras)
        listOfExtras = { 'Line.ShowValues', 'showValues' 
                         'Bar.ShowValues',  'showValues' };
    end

    if testLevel
        level = getappdata(handle, 'IRIS_BackgroundLevel');
        if validate.numericScalar(level) && level<0
            addCount = 0;
            return
        end
    end
    addCount = 1;

    errors = runPreAndPost('Prestyle', handle, type, specs, j, errors); 
    propertyNames = fieldnames(specs);
    numProperties = numel(propertyNames);
    for i = 1 : numProperties
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
        if isequal(assignValue, @auto)
            continue
        end
        try
            currentValue = get(handle, ithPropertyName);
            if isgraphics(currentValue)
                errors = apply(currentValue, ithPropertyName, assignValue, j, errors, testLevel);
                continue
            end
        end
        inxExtras = strcmpi([type, '.', ithPropertyName], listOfExtras(:, 1));
        try
            if any(inxExtras)
                extraFunctionName = listOfExtras{inxExtras, 2};
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

