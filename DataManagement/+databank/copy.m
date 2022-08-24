% >=R2019b
%{
function targetDb = copy(sourceDb, opt)

arguments
    sourceDb (1, 1) {validate.databank(sourceDb)}

    opt.SourceNames {local_validateNames(opt.SourceNames)} = @all
    opt.TargetNames {local_validateNames(opt.TargetNames)} = @auto
    opt.TargetDb {local_validateDb(opt.TargetDb)} = @empty
    opt.Transform {local_validateTransform(opt.Transform)} = cell.empty(1, 0)
    opt.WhenTransformFails {local_validateWhenTransformFails} = "error"
end
%}
% >=R2019b


% <=R2019a
%(
function targetDb = copy(sourceDb, varargin)

persistent ip
if isempty(ip)
    ip = inputParser(); 
    addParameter(ip, "SourceNames", @all);
    addParameter(ip, "TargetNames", @auto);
    addParameter(ip, "TargetDb", @empty);
    addParameter(ip, "Transform", cell.empty(1, 0));
    addParameter(ip, "WhenTransformFails", "error");
end
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


transform = opt.Transform;

%
% Resolve source names
%
sourceNames = here_resolveSourceNames();

%
% Resolve target databank
%
targetDb = here_resolveTargetDb();

%
% Resolve target names
%
targetNames = here_resolveTargetNames();

numSourceNames = numel(sourceNames);
here_checkDimensions();

inxSuccess = true(1, numSourceNames);
for i = 1 : numSourceNames
    sourceName__ = sourceNames(i);
    targetName__ = targetNames(i);
    value = sourceDb.(char(sourceName__));
    try
        value = iris.utils.applyFunctions(value, transform);
    catch
        inxSuccess(i) = false;
        continue
    end
    if isa(targetDb, 'Dictionary')
        store(targetDb, targetName__, value);
    elseif isstruct(targetDb)
        targetDb.(char(targetName__)) = value;
    end
end

if any(~inxSuccess)
    here_throwTransformFailed();
end

return

    function sourceNames = here_resolveSourceNames()
        %(
        testForAll = @(x) isequal(x, @all) || isequal(x, "__all__") || isequal(x, '__all__');
        if testForAll(opt.SourceNames)
            sourceNames = databank.fieldNames(sourceDb);
        elseif isa(opt.SourceNames, 'function_handle') 
            func = opt.SourceNames;
            sourceNames = databank.fieldNames(sourceDb);
            numSourceNames = numel(sourceNames);
            inxPass = true(1, numSourceNames);
            for i = 1 : numSourceNames
                inxPass(i) = logical(func(sourceNames(i)));
            end
            sourceNames = sourceNames(inxPass);
        else
            sourceNames = textual.stringify(opt.SourceNames);
        end
        %)
    end%


    function targetDb = here_resolveTargetDb()
        targetDb = opt.TargetDb;
        if isequal(targetDb, @empty)
            if isa(sourceDb, 'Dictionary')
                targetDb = Dictionary();
            elseif isstruct(sourceDb)
                targetDb = struct();
            end
        end
    end%


    function targetNames = here_resolveTargetNames()
        %(
        if isequal(opt.TargetNames, @auto) || all(strcmpi(opt.TargetNames, '__auto__'))
            targetNames = sourceNames;
        elseif isa(opt.TargetNames, 'function_handle') || (iscell(opt.TargetNames) && ~iscellstr(opt.TargetNames))
            targetNames = sourceNames;
            for i = 1 : numel(targetNames)
                targetNames(i) = iris.utils.applyFunctions(targetNames(i), opt.TargetNames);
            end
        else
            targetNames = textual.stringify(opt.TargetNames);
        end
        %)
    end%


    function here_checkDimensions()
        numTargetNames = numel(targetNames);
        if numSourceNames~=numTargetNames
            thisError = [
                "Databank:InvalidDimensionOfNames"
                "Number of source names must match number of target names: %s"
            ];
            report = numSourceNames + "~=" + numTargetNames;
            throw(exception.ParseTime(thisError, 'error'), report);
        end
    end%


    function here_throwTransformFailed()
        thisError = [
            "Databank:TransformFailed"
            "Transformation function failed when applied to this source databank field: %s"
        ];
        throw(exception.Base(thisError, opt.WhenTransformFails), sourceNames(~inxSuccess));
    end%
end%

%
% Local Functions
%

function local_validateNames(input)
    if isa(input, 'function_handle') || iscell(input) || validate.list(input)
        return
    end
    error("Validation:Failed", "Input value must be a string array");
end%


function local_validateDb(input)
    if isa(input, 'function_handle') || validate.databank(input)
        return
    end
    error("Validation:Failed", "Input value must be a struct or a Dictionary");
end%


function local_validateTransform(input)
    if isempty(input) || isa(input, 'function_handle') || (iscell(input) && all(cellfun(@(x) isa(x, "function_handle"), input)))
        return
    end
    error("Validation:Failed", "Input value must be empty or a function handle");
end%


function local_validateWhenTransformFails(input)
    if startsWith(input, ["error", "warning"], "ignoreCase", true)
        return
    end
    error("Validation:Failed", "Input value must be ""Error"" or ""Warning""");
end%

