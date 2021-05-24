% Type `web +databank/apply.md` for help on this function
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

% >=R2019b
%(
function [outputDb, appliedToNames, newNames] = apply(inputDb, func, opt)

arguments
    inputDb (1, 1) {locallyValidateInputDbOrFunc}
    func (1, 1) {locallyValidateInputDbOrFunc}

    opt.StartsWith (1, 1) string = ""
    opt.HasPrefix (1, 1) string = ""

    opt.EndsWith (1, 1) string = ""
    opt.HasSuffix (1, 1) string = ""

    opt.AddToStart (1, 1) string = ""
    opt.AddPrefix (1, 1) string = ""

    opt.AddToEnd (1, 1) string = ""
    opt.AddSuffix (1, 1) string = ""

    opt.RemoveStart (1, 1) logical = false
    opt.RemovePrefix (1, 1) logical = false

    opt.RemoveEnd (1, 1) logical = false
    opt.RemoveSuffix (1, 1) logical = false

    opt.RemoveSource (1, 1) logical = false
    opt.SourceNames {locallyValidateNames} = @all
    opt.TargetNames {locallyValidateNames} = @default
    opt.AddToDatabank {locallyValidateDb} = @default
    opt.TargetDb {locallyValidateDb} = @default
end

if strlength(opt.HasPrefix)>0
    opt.StartsWith = opt.HasPrefix;
end

if strlength(opt.HasSuffix)>0
    opt.EndsWith = opt.HasSuffix;
end

if strlength(opt.AddPrefix)>0
    opt.AddToStart = opt.AddPrefix;
end

if strlength(opt.AddSuffix)>0
    opt.AddToEnd = opt.AddSuffix;
end

if opt.RemovePrefix
    opt.RemoveStart = opt.RemovePrefix;
end

if opt.RemoveSuffix
    opt.RemoveEnd = opt.RemoveSuffix;
end

if ~isequal(opt.TargetDb, @default)
    opt.AddToDatabank = opt.TargetDb;
end
%)
% >=R2019b


if validate.databank(func)
    [func, inputDb] = deal(inputDb, func);
end


% <=R2019a
%{
function [outputDb, appliedToNames, newNames] = apply(inputDb, func, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser('databank.apply');
    pp.addRequired('Function', @(x) isempty(x) || isa(x, 'function_handle'));
    pp.addRequired('InputDatabank', @validate.databank);

    pp.addParameter({'StartsWith', 'HasPrefix'}, '',  @(x) ischar(x) || (isa(x, 'string') && isscalar(x)));
    pp.addParameter({'EndsWith', 'HasSuffix'}, '',  @(x) ischar(x) || (isa(x, 'string') && isscalar(x)));
    pp.addParameter({'AddToStart', 'AddPrefix', 'Prepend'}, '',  @(x) ischar(x) || (isa(x, 'string') && isscalar(x)));
    pp.addParameter({'AddToEnd', 'AddSuffix', 'Append'}, '',  @(x) ischar(x) || (isa(x, 'string') && isscalar(x)));
    pp.addParameter({'RemoveStart', 'RemovePrefix'}, false, @validate.logicalScalar);
    pp.addParameter({'RemoveEnd', 'RemoveSuffix'}, false, @validate.logicalScalar);
    pp.addParameter('RemoveSource', false, @validate.logicalScalar);
    pp.addParameter({'SourceNames', 'Names', 'Fields', 'InputNames'}, @all, @(x) isequal(x, @all) || validate.list(x) || isa(x, 'Rxp'));
    pp.addParameter({'TargetNames', 'OutputNames'}, @default, @(x) isequal(x, @default) || validate.list(x));
    pp.addParameter({'AddToDatabank', 'TargetDb'}, @default, @(x) isequal(x, @default) || validate.databank(x));
end
opt = pp.parse(func, inputDb, varargin{:});
%}
% <=R2019a


if ~isa(opt.SourceNames, 'function_handle')
    if isa(opt.SourceNames, 'Rxp')
        opt.SourceNames = databank.filter(inputDb, 'name', opt.SourceNames);
    end
    opt.SourceNames = cellstr(opt.SourceNames);
end

opt.StartsWith = char(opt.StartsWith);
opt.EndsWith = char(opt.EndsWith);
opt.AddToStart = char(opt.AddToStart);
opt.AddToEnd = char(opt.AddToEnd);

hereCheckInputOutputNames( );

%--------------------------------------------------------------------------

if isa(inputDb, 'Dictionary')
    namesFields = cellstr(keys(inputDb));
elseif isstruct(inputDb)
    namesFields = fieldnames(inputDb);
end

numFields = numel(namesFields);
newNames = repmat({''}, size(namesFields));


outputDb = opt.AddToDatabank;
if isequal(outputDb, @default)
    outputDb = inputDb;
end

inxApplied = false(1, numFields);
inxToRemove = false(1, numFields);
for i = 1 : numFields
    name__ = namesFields{i};
    if ~isa(opt.SourceNames, 'function_handle') && ~any(strcmpi(name__, opt.SourceNames))
       continue
    end 
    if ~isempty(opt.StartsWith) && ~startsWith(name__, opt.StartsWith)
        continue
    end
    if ~isempty(opt.EndsWith) && ~endsWith(name__, opt.EndsWith)
        continue
    end

    inxApplied(i) = true;

    %
    % Create output field name
    %
    if iscellstr(opt.TargetNames)
        inxName = strcmp(opt.SourceNames, name__);
        newName__ = opt.TargetNames{inxName};
    else
        newName__ = name__;
        if opt.RemoveStart
            newName__ = extractAfter(newName__, strlength(opt.StartsWith));
        end
        if opt.RemoveEnd
            newName__ = extractBefore(newName__, strlength(newName__)-strlength(opt.EndsWith)+1);
        end
        if ~isempty(opt.AddToStart)
            newName__ = [opt.AddToStart, newName__];
        end
        if ~isempty(opt.AddToEnd)
            newName__ = [newName__, opt.AddToEnd];
        end
    end
    newNames{i} = newName__;

    field__ = inputDb.(name__);
    if ~isempty(func)
        field__ = func(field__);
    end
    if isa(outputDb, 'Dictionary')
        store(outputDb, newName__, field__);
    else
        outputDb.(newName__) = field__;
    end
    inxToRemove(i) = opt.RemoveSource && ~strcmp(name__, newName__);
end

if any(inxToRemove)
    outputDb = rmfield(outputDb, namesFields(inxToRemove));
end

appliedToNames = namesFields(inxApplied);
newNames = newNames(inxApplied);

return


    function hereCheckInputOutputNames( )
        if isa(opt.TargetNames, 'function_handle')
            return
        end
        if validate.list(opt.SourceNames)
            opt.SourceNames = cellstr(opt.SourceNames);
        end
        if validate.list(opt.TargetNames)
            opt.TargetNames = cellstr(opt.TargetNames);
        end
        if iscellstr(opt.TargetNames) 
            if iscellstr(opt.TargetNames) && numel(opt.SourceNames)==numel(opt.TargetNames)
                return
            end
        end
        exception.error([
            "Databank:InconsistentInputOutputNames"
            "When used together in databank.apply(~), "
            "options SourceNames= and TargetNames= "
            "must be lists of the same size"
        ]);
    end%
end%


function locallyValidateInputDbOrFunc(input)
    if isempty(input) || validate.databank(input) || isa(input, 'function_handle')
        return
    end
    error("Validation:Failed", "Input value must empty, a databank or a function handle");
end%


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

