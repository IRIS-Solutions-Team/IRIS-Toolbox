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


sourceNames = opt.SourceNames;
targetNames = opt.TargetNames;
transform = opt.Transform;
if ~iscell(transform)
    transform = {transform};
end

%
% Resolve source names
%
sourceNames = hereResolveSourceNames( );

%
% Resolve target databank
%
targetDb = hereResolveTargetDb( );

%
% Resolve target names
%
targetNames = hereResolveTargetNames( );

numSourceNames = numel(sourceNames);
hereCheckDimensions( );

inxSuccess = true(1, numSourceNames);
for i = 1 : numSourceNames
    sourceName__ = sourceNames(i);
    targetName__ = targetNames(i);
    value = sourceDb.(char(sourceName__));
    if ~isempty(transform)
        try
            for f = reshape(transform, 1, [])
                value = f{1}(value);
            end
        catch
            inxSuccess(i) = false;
            continue
        end
    end
    if isa(targetDb, 'Dictionary')
        store(targetDb, targetName__, value);
    elseif isstruct(targetDb)
        targetDb.(char(targetName__)) = value;
    end
end

if any(~inxSuccess)
    hereThrowTransformFailed( );
end

return

    function sourceNames = hereResolveSourceNames( )
        sourceNames = opt.SourceNames;
        if isa(sourceNames, 'function_handle')
            func = sourceNames;
            if isa(sourceDb, 'Dictionary')
                sourceNames = keys(sourceDb);
            else
                sourceNames = reshape(string(fieldnames(sourceDb)), 1, []);
            end
            if ~isequal(func, @all)
                inxPass = func(sourceNames);
                sourceNames = sourceNames(inxPass);
            end
        else
            sourceNames = reshape(string(sourceNames), 1, []);
        end
    end%


    function targetDb = hereResolveTargetDb( )
        targetDb = opt.TargetDb;
        if isequal(targetDb, @empty)
            if isa(sourceDb, 'Dictionary')
                targetDb = Dictionary( );
            elseif isstruct(sourceDb)
                targetDb = struct( );
            end
        end
    end%


    function targetNames = hereResolveTargetNames( )
        targetNames = opt.TargetNames;
        if isequal(targetNames, @auto)
            targetNames = sourceNames;
        elseif isa(targetNames, 'function_handle')
            targetNames = arrayfun(targetNames, sourceNames);
        else
            targetNames = string(targetNames);
        end
    end%


    function hereCheckDimensions( )
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


    function hereThrowTransformFailed( )
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
    if isa(input, 'function_handle') || validate.list(input)
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

