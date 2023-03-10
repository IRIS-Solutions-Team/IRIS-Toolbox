%{
% 
% # `databank.copy` ^^(+databank)^^
% 
% {== Copy fields of source databank to target databank ==}
% 
% 
% ## Syntax
% 
%     targetDb = databank.copy(sourceDb, ...)
% 
% 
% ## Input Arguments
% 
% __`sourceDb`__ [ struct | Dictionary ]
% > 
% > Source databank from which some (or all) fields will be copied over
% > to the `targetDb`.
% > 
% 
% ## Options
% 
% __`SourceNames=@all`__ [ `@all` | cellstr | string ]
% > 
% > List of fieldnames to be copied over from the `sourceDb` to the
% > `targetDb`; `@all` means all fields existing in the `sourceDb` will
% > be copied.
% > 
% 
% __`TargetDb=@empty`__ [ `@empty` | struct | Dictionary ]
% > 
% > Target databank to which some (or all) fields form the `sourceDb`
% > will be copied over; `@empty` means a new empty databank will be
% > created of the same type as the `sourceDb` (either a struct or a
% > Dictionary).
% > 
% 
% __`TargetNames=@auto`__ [ cellstr | string | function_handle ]
% > 
% > Names under which the fields from the `sourceDb` will be stored in
% > the `targetDb`; `@auto` means the `TargetNames` will be simply the
% > same as the `SourceNames`; if `TargetNames` is a function, the target
% > names will be created by applying this function to each of
% > the `SourceNames`.
% > 
% 
% __`Transform={}`__ [ empty | function_handle | cell ]
% > 
% > Transformation function or functions applied to each of the fields being
% > copied over from the `sourceDb` to the `targetDb`; if empty, no
% > transformation is performed; if a cell array of functions, each function
% > will be applied consecutively.
% > 
% 
% __`WhenTransformFails='Error'`__ [ `'Error'` | `'Warning'` | `'Silence'` ]
% > 
% > Action to be taken if the transformation function `Transform=`
% > evaluates to an error when applied to one or more fields of the source
% > databank.
% > 
% 
% ## Output Arguments
% 
% __`targetDb`__ [ struct | Dictionary ]
% > 
% > Target databank to which some (or all) fields from the `sourceDb`
% > will be copied over.
% > 
% 
% ## Description
% 
% 
% ## Example
% 
% 
%}
% --8<--


% >=R2019b
%{
function targetDb = copy(sourceDb, opt)

arguments
    sourceDb (1, 1) {validate.databank(sourceDb)}

    opt.SourceNames {local_validateNames(opt.SourceNames)} = @all
    opt.TargetNames {local_validateNames(opt.TargetNames)} = @auto
    opt.TargetDb {local_validateDb(opt.TargetDb)} = @empty
    opt.Transform {local_validateTransform(opt.Transform)} = cell.empty(1, 0)
    opt.WhenTransformFails {local_validateWhen} = "error"
    opt.WhenMissing {local_validateWhen} = "error"
    opt.RemoveSource (1, 1) logical = false
    opt.WhenTargetExists (1, 1) string {mustBeMember(opt.WhenTargetExists, ["error", "warning", "silent"])} = "error"
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
    addParameter(ip, "WhenMissing", "error");
    addParameter(ip, "RemoveStart", false);
    addParameter(ip, "RemoveSource", false);
    addParameter(ip, "WhenTargetExists", "error");
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
inxMissing = true(1, numSourceNames);
namesToRemove = string.empty(1, 0);
targetExists = string.empty(1, 0);
for i = 1 : numSourceNames
    sourceName__ = sourceNames(i);
    targetName__ = targetNames(i);
    if ~isfield(sourceDb, char(sourceName__))
        inxMissing(i) = false;
        continue
    end
    value = sourceDb.(char(sourceName__));
    try
        value = iris.utils.applyFunctions(value, transform);
    catch
        inxSuccess(i) = false;
        continue
    end

    if isfield(targetDb, targetName__)
        targetExists(end+1) = targetName__;
    end

    if isa(targetDb, 'Dictionary')
        store(targetDb, targetName__, value);
    elseif isstruct(targetDb)
        targetDb.(char(targetName__)) = value;
    end

    if opt.RemoveSource && sourceName__~=targetName__ && isfield(targetDb, sourceName__)
        namesToRemove(end+1) = sourceName__;
    end
end


if ~isempty(targetExists)
    switch opt.WhenTargetExists
        case "error"
            func = @exception.error;
        case "warning"
            func = @exception.warning;
        case "silent"
            func = @exception.silent;
    end
    func(["Databank", "This target name already exists in the target databank: %s"], targetExists);
end

if ~isempty(namesToRemove)
    targetDb = rmfield(targetDb, namesToRemove);
end

if any(~inxSuccess)
    here_throwTransformFailed();
end

if any(~inxMissing)
    here_throwMissing();
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


    function here_throwMissing()
        thisError = [
            "Databank:TransformFailed"
            "This field is not in the source databank: %s"
        ];
        throw(exception.Base(thisError, opt.WhenMissing), sourceNames(~inxMissing));
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


function local_validateWhen(input)
    if startsWith(input, ["error", "warning", "silent"], "ignoreCase", true)
        return
    end
    error("Validation:Failed", "Input value must be ""error"" or ""warning"" or ""silent"" ");
end%

