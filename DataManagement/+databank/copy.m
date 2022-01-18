% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 [IrisToolbox] Solutions Team

% >=R2019b
%(
function targetDb = copy(sourceDb, opt)

arguments
    sourceDb (1, 1) {validate.databank(sourceDb)}

    opt.SourceNames {locallyValidateNames(opt.SourceNames)} = @all
    opt.TargetNames {locallyValidateNames(opt.TargetNames)} = @auto
    opt.TargetDb {locallyValidateDb(opt.TargetDb)} = @empty
    opt.Transform {locallyValidateTransform(opt.Transform)} = cell.empty(1, 0)
    opt.WhenTransformFails {locallyValidateWhenTransformFails} = "error"
end
%)
% >=R2019b


% <=R2019a
%{
function targetDb = copy(sourceDb, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser("databank.copy");
    addRequired(pp, "sourceDb", @validate.databank);

    addParameter(pp, "SourceNames", @all, @locallyValidateNames);
    addParameter(pp, "TargetNames", @auto, @locallyValidateNames);
    addParameter(pp, "TargetDb", @empty, @locallyValidateDb);
    addParameter(pp, "Transform", cell.empty(1, 0), @locallyValidateTransform);
    addParameter(pp, "WhenTransformFails", "error", @locallyValidateWhenTransformFails);
end
opt = parse(pp, sourceDb, varargin{:});
%}
% <=R2019a


transform = opt.Transform;

%
% Resolve source names
%
sourceNames = hereResolveSourceNames();

%
% Resolve target databank
%
targetDb = hereResolveTargetDb();

%
% Resolve target names
%
targetNames = hereResolveTargetNames();

numSourceNames = numel(sourceNames);
hereCheckDimensions();

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
    hereThrowTransformFailed();
end

return

    function sourceNames = hereResolveSourceNames()
        %(
        if isequal(opt.SourceNames, @all) || isequal(opt.SourceNames, "__all__")
            sourceNames = databank.fieldNames(sourceDb);
        elseif isa(opt.SourceNames, 'function_handle') 
            sourceNames = databank.fieldNames(sourceDb);
            inxPass = func(sourceNames);
            sourceNames = sourceNames(inxPass);
        else
            sourceNames = textual.stringify(opt.SourceNames);
        end
        %)
    end%


    function targetDb = hereResolveTargetDb()
        targetDb = opt.TargetDb;
        if isequal(targetDb, @empty)
            if isa(sourceDb, 'Dictionary')
                targetDb = Dictionary();
            elseif isstruct(sourceDb)
                targetDb = struct();
            end
        end
    end%


    function targetNames = hereResolveTargetNames()
        %(
        if isequal(opt.TargetNames, @auto) || isequal(opt.TargetNames, "__auto__")
            targetNames = sourceNames;
        elseif isa(opt.TargetNames, 'function_handle') || iscell(opt.TargetNames)
            targetNames = sourceNames;
            for i = 1 : numel(targetNames)
                targetNames(i) = iris.utils.applyFunctions(targetNames(i), opt.TargetNames);
            end
        else
            targetNames = textual.stringify(opt.TargetNames);
        end
        %)
    end%


    function hereCheckDimensions()
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


    function hereThrowTransformFailed()
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

function locallyValidateNames(input)
    if isa(input, 'function_handle') || iscell(input) || validate.list(input)
        return
    end
    error("Validation:Failed", "Input value must be a string array");
end%


function locallyValidateDb(input)
    if isa(input, 'function_handle') || validate.databank(input)
        return
    end
    error("Validation:Failed", "Input value must be a struct or a Dictionary");
end%


function locallyValidateTransform(input)
    if isempty(input) || isa(input, 'function_handle') || (iscell(input) && all(cellfun(@(x) isa(x, "function_handle"), input)))
        return
    end
    error("Validation:Failed", "Input value must be empty or a function handle");
end%


function locallyValidateWhenTransformFails(input)
    if startsWith(input, ["error", "warning"], "ignoreCase", true)
        return
    end
    error("Validation:Failed", "Input value must be ""Error"" or ""Warning""");
end%

