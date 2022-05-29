
% >=R2019b
%{
function outputDb = generate(inputDb, valueFunc, targetNames, inputArgNames, opt)

arguments
    inputDb {validate.mustBeDatabank}
    valueFunc {mustBeA(valueFunc, "function_handle")}
    targetNames {local_validateTargetNames}
    inputArgNames {local_validateInputArgNames}

    opt.TargetDb {validate.databank} = inputDb
end
%}
% >=R2019b


% <=R2019a
%(
function outputDb = generate(inputDb, valueFunc, targetNames, inputArgNames, varargin)

persistent ip
if isempty(ip)
    ip = inputParser(); 
    addParameter(ip, "TargetDb", inputDb);
end
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


outputDb = opt.TargetDb;

isFunc = isa(targetNames, "function_handle");
if ~isFunc
    targetNames = textual.stringify(targetNames);
end


if iscell(inputArgNames)
    inputArgNames = vertcat(inputArgNames{:});
end


for i = 1 : size(inputArgNames, 1)
    names = textual.stringify(inputArgNames(i, :));
    names = num2cell(names);
    values = cell(size(names));
    for j = 1 : numel(names)
        values{j} = inputDb.(names{j});
    end

    if isFunc
        newName = targetNames(names{:});
    else
        newName = targetNames(i);
    end

    outputDb.(newName) = valueFunc(values{:});
end

end%

%
% Local functions
%

function local_validateInputArgNames(x)
    %(
    if isstring(x) 
        return
    end
    if iscell(x) && all(cellfun(@(y) isstring(y), x)) && allEqual(cellfun(@numel, x))
        return
    end
    error("Input value must be a string array or a cell array of strings.");
    %)
end%


function local_validateTargetNames(x)
    %(
    if isstring(x)
        return
    end
    if isa(x, 'function_handle')
        return
    end
    error("Input value must be a string array or a function.");
    %)
end%

