% databank.apply  Apply function to selection of databank fields
%{
% Syntax
%--------------------------------------------------------------------------
%
%     [outputDb, appliedToNames, newNames] = apply(inputDb, func, ...) 
%
% 
% Input Arguments
%--------------------------------------------------------------------------
%
% __`inputDb`__ [ struct | Dictionary ]
%
%>    Input databank to whose fields the `function` will be applied.
%
%
% __`function`__ [ function_handle ]
%
%>    Function (function handle) that will be applied to the selected fields of
%>    the `inputDb`.
%
%
% Output Arguments
%--------------------------------------------------------------------------
%
% __`outputDb`__ [ struct | Dictionary ]
%
%>    Output databank created from the `inputDb` with new fields or some
%>    fields modified.
%
%
% __`appliedToNames`__ [ cellstr | string ] 
% List of names to which the `function` has been actually applied.
%
%
% __`newNames`__ [ cellstr | string ] 
%
%>    List of names under which the results are stored in the `outputDb`.
%
%
% Options
%--------------------------------------------------------------------------
%
% __`StartsWith=""`__ [ char | string ] 
%
%>    Apply the `function` to fields whose names start with this string.
%
%
% __`EndsWith=""`__ [ char | string ] 
%
%>    Apply the `function` to fields whose names end with this string.
%
%
% __`RemoveStart=false`__ [ `true` | `false` ] 
%
%>    If option `StartsWith=` was used, a new field will be created after the
%>    `function` has been applied with its named derived from the original name
%>    by removing the start of the string.
%
%
% __`RemoveEnd=false`__ [ `true` | `false` ] 
%
%>    If option `EndsWith=` was used, a new field will be created after the
%>    `function` has been applied with its named derived from the original name
%>    by removing the end of the string.
%>    
%
% __`Prepend=""`__ [ char | string ] 
%
%>    A new field will be created after the `function` has been applied with
%>    its named derived from the original name by prepending this string to the
%>    beginning of the original field name.
% 
%
% __`Append=""`__ [ char | string ] 
%
%>    A new field will be created after the `function` has been applied with
%>    its named derived from the original name by appending this string to the
%>    end of the original field name.
%
%
% __`RemoveSource=false`__ [ `true` | `false` ] 
%
%>    Remove the source field from the `outputDb`; the source field is
%>    the `inputDb` on which the `function` was run to create a new
%>    field.
%
% __`SourceNames=@all`__ [ `@all` | cellstr | string ] 
%
%>    List of databank field names to which the name selection procedure will
%>    be reduced.
%
%
% __`TargetNames=@default`__ [ `@default` | cellstr | string ] 
%
%>    New names for output databank fields.
%
%
% Description
%--------------------------------------------------------------------------
%
%
% Example
%--------------------------------------------------------------------------
%
%     >> d1 = struct( );
%     >> d1.x = Series(1:10, 1:10);
%     >> d1.b = 1:5;
%     >> d1.y_u = Series(qq(2010,1):qq(2025,4), @rand);
%     >>er d
%
%     d2 = 
%     
%       struct with fields:
%     
%           x: [10x1 Series]
%           b: [2 3 4 5 6]
%         y_u: [64x1 Series]2 = databank.apply(@(x) x+1, d1)
%
%
% Example
%--------------------------------------------------------------------------
%
%     >> d1 = struct( );
%     >> d1.x = Series(1:10, 1:10);
%     >> d1.b = 1:5;
%     >> d1.y_u = Series(qq(2010,1):qq(2025,4), @rand);
%     >> d2 = databank.apply(@(x) x+1, d1, 'EndsWith=', '_u', 'RemoveEnd=', true);
%     >> disp(d2)
%
%     d2 = 
%
%     struct with fields:
%
%         x: [10x1 Series]
%         b: [1 2 3 4 5]
%       y_u: [64x1 Series]
%         y: [64x1 Series]
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function [outputDb, appliedToNames, newNames] = apply(inputDb, func, opt)

% >=R2019b
%{
arguments
    inputDb (1, 1) {locallyValidateInputDbOrFunc}
    func (1, 1) {locallyValidateInputDbOrFunc}

    opt.StartsWith {validate.mustBeTextScalar} = ""
    opt.HasPrefix {validate.mustBeTextScalar} = ""

    opt.EndsWith {validate.mustBeTextScalar} = ""
    opt.HasSuffix {validate.mustBeTextScalar} = ""

    opt.AddToStart {validate.mustBeTextScalar} = ""
    opt.AddPrefix {validate.mustBeTextScalar} = ""

    opt.AddToEnd {validate.mustBeTextScalar} = ""
    opt.AddSuffix {validate.mustBeTextScalar} = ""

    opt.RemoveStart (1, 1) {validate.mustBeA(opt.RemoveStart, "logical")} = false
    opt.RemovePrefix (1, 1) {validate.mustBeA(opt.RemovePrefix, "logical")} = false

    opt.RemoveEnd (1, 1) {validate.mustBeA(opt.RemoveEnd, "logical")} = false
    opt.RemoveSuffix (1, 1) {validate.mustBeA(opt.RemoveSuffix, "logical")} = false

    opt.RemoveSource (1, 1) {validate.mustBeA(opt.RemoveSource, "logical")} = false
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
%}
% >=R2019b

if validate.databank(func)
    [func, inputDb] = deal(inputDb, func);
end

% <=R2019a
%(
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
%)
% <=R2019a

if ~isa(opt.SourceNames, "function_handle")
    if isa(opt.SourceNames, 'Rxp')
        opt.SourceNames = databank.filter(inputDb, 'Name=', opt.SourceNames);
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
    if ~isa(opt.SourceNames, "function_handle") && ~any(strcmpi(name__, opt.SourceNames))
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
            newName__ = extractBefore(newName__, strlength(newName__)-strlength(opt.HasSuffix)+1);
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
    if isa(outputDb, "Dictionary")
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
        if isa(opt.TargetNames, "function_handle")
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
    if isempty(input) || validate.databank(input) || isa(input, "function_handle")
        return
    end
    error("Validation:Failed", "Input value must empty, a databank or a function handle");
end%


function locallyValidateNames(input)
    if isa(input, "function_handle") || validate.list(input)
        return
    end
    error("Validation:Failed", "Input value must be a string array");
end%


function locallyValidateDb(input)
    if isa(input, "function_handle") || validate.databank(input)
        return
    end
    error("Validation:Failed", "Input value must be a struct or a Dictionary");
end%

