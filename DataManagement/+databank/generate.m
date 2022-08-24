% >=R2019b
%{
function outputDb = generate(inputDb, valueFunc, targetNames, sourceNames, opt)

arguments
    inputDb {validate.mustBeDatabank}
    valueFunc {mustBeA(valueFunc, "function_handle")}
    targetNames {local_validateTargetNames}
    sourceNames {local_validateSourceNames}

    opt.TargetDb {validate.databank} = struct([])
end
%}
% >=R2019b


% <=R2019a
%(
function outputDb = generate(inputDb, valueFunc, targetNames, sourceNames, varargin)

persistent ip
if isempty(ip)
    ip = inputParser(); 

    addParameter(ip, "TargetDb", struct([]));
end
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


    if isempty(opt.TargetDb)
        outputDb = inputDb;
    else
        outputDb = opt.TargetDb;
    end

    isFunc = isa(targetNames, "function_handle");
    if ~isFunc
        targetNames = textual.stringify(targetNames);
    end


    [sourceNames, numToGenerate] = local_consolidateSourceNames(sourceNames, targetNames);
    numSource = numel(sourceNames);

    for i = 1 : numToGenerate
        sourceValues = cell(1, numSource);
        for j = 1 : numSource
            if isstring(sourceNames{j})
                n = sourceNames{j}(i);
            else
                n = sourceNames{j}(sourceNames{1}(i));
            end
            sourceValues{j} = inputDb.(n);
        end

        if isstring(targetNames)
            newName = targetNames(i);
        else
            newName = targetNames(sourceNames{1}(i));
        end

        outputDb.(newName) = valueFunc(sourceValues{:});
    end

end%

%
% Local functions
%

function local_validateSourceNames(x)
    %(
    if isstring(x) 
        return
    end
    if iscell(x) && all(cellfun(@(y) iscellstr(y) || isstring(y) || isa(y, 'function_handle'), x))
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


function [sourceNames, numToGenerate] = local_consolidateSourceNames(sourceNames, targetNames)
    %(
    test = @(c) iscellstr(c) || isstring(c);
    if ~iscell(sourceNames)
        sourceNames = {sourceNames};
    end
    sourceNames = reshape(sourceNames, 1, []);
    numToGenerate = [];
    for i = 1 : numel(sourceNames)
        if test(sourceNames{i})
            sourceNames{i} = textual.stringify(sourceNames{i});
            numToGenerate = [numToGenerate, numel(sourceNames{i})];
        elseif i==1
            exception.error([
                "Databank"
                "First input argument into the generator function must be a vector of strings."
            ]);
        end
    end
    if test(targetNames)
        numToGenerate = [numToGenerate, numel(targetNames)];
    end
    if any(numToGenerate~=numToGenerate(1))
        exception.error([
            "Databank"
            "Number of all source names and target names must be the same."
        ]);
    end
    %)
end%

