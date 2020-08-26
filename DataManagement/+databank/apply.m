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
% __`InputNames=@all`__ [ `@all` | cellstr | string ] 
%
%>    List of databank field names to which the name selection procedure will
%>    be reduced.
%
%
% __`OutputNames=@default`__ [ `@default` | cellstr | string ] 
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

function [outputDb, appliedToNames, newNames] = apply(inputDb, func, varargin)

%--------------------------------------------------------------------------

if validate.databank(func)
    [func, inputDb] = deal(inputDb, func);
end

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('databank.apply');
    pp.addRequired('Function', @(x) isempty(x) || isa(x, 'function_handle'));
    pp.addRequired('InputDatabank', @validate.databank);

    pp.addParameter({'HasPrefix', 'StartsWith'}, '',  @(x) ischar(x) || (isa(x, 'string') && isscalar(x)));
    pp.addParameter({'HasSuffix', 'EndsWith'}, '',  @(x) ischar(x) || (isa(x, 'string') && isscalar(x)));
    pp.addParameter({'AddPrefix', 'AddToStart', 'Prepend'}, '',  @(x) ischar(x) || (isa(x, 'string') && isscalar(x)));
    pp.addParameter({'AddSuffix', 'AddToEnd', 'Append'}, '',  @(x) ischar(x) || (isa(x, 'string') && isscalar(x)));
    pp.addParameter({'RemovePrefix', 'RemoveStart'}, false, @validate.logicalScalar);
    pp.addParameter({'RemoveSuffix', 'RemoveEnd'}, false, @validate.logicalScalar);
    pp.addParameter('RemoveSource', false, @validate.logicalScalar);
    pp.addParameter({'InputNames', 'Names', 'Fields', 'SourceNames'}, @all, @(x) isequal(x, @all) || validate.list(x) || isa(x, 'Rxp'));
    pp.addParameter({'OutputNames', 'TargetNames'}, @default, @(x) isequal(x, @default) || validate.list(x));
    pp.addParameter('AddToDatabank', @default, @(x) isequal(x, @default) || validate.databank(x));
end
%)
opt = pp.parse(func, inputDb, varargin{:});

if ~isequal(opt.InputNames, @all)
    if isa(opt.InputNames, 'Rxp')
        opt.InputNames = databank.filter(inputDb, 'Name=', opt.InputNames);
    end
    opt.InputNames = cellstr(opt.InputNames);
end

opt.HasPrefix = char(opt.HasPrefix);
opt.HasSuffix = char(opt.HasSuffix);
opt.AddPrefix = char(opt.AddPrefix);
opt.AddSuffix = char(opt.AddSuffix);

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
    if ~isequal(opt.InputNames, @all) && ~any(strcmpi(name__, opt.InputNames))
       continue
    end 
    if ~isempty(opt.HasPrefix) && ~startsWith(name__, opt.HasPrefix)
        continue
    end
    if ~isempty(opt.HasSuffix) && ~endsWith(name__, opt.HasSuffix)
        continue
    end

    inxApplied(i) = true;

    %
    % Create output field name
    %
    if iscellstr(opt.OutputNames)
        inxName = strcmp(opt.InputNames, name__);
        newName__ = opt.OutputNames{inxName};
    else
        newName__ = name__;
        if opt.RemovePrefix
            newName__ = extractAfter(newName__, strlength(opt.HasPrefix));
        end
        if opt.RemoveSuffix
            newName__ = extractBefore(newName__, strlength(newName__)-strlength(opt.HasSuffix)+1);
        end
        if ~isempty(opt.AddPrefix)
            newName__ = [opt.AddPrefix, newName__];
        end
        if ~isempty(opt.AddSuffix)
            newName__ = [newName__, opt.AddSuffix];
        end
    end
    newNames{i} = newName__;

    field__ = inputDb.(name__);
    if ~isempty(func)
        field__ = func(field__);
    end
    outputDb.(newName__) = field__;
    inxToRemove(i) = opt.RemoveSource && ~strcmp(name__, newName__);
end

if any(inxToRemove)
    outputDb = rmfield(outputDb, namesFields(inxToRemove));
end

appliedToNames = namesFields(inxApplied);
newNames = newNames(inxApplied);

return


    function hereCheckInputOutputNames( )
        if isequal(opt.OutputNames, @default)
            return
        end
        if validate.list(opt.InputNames)
            opt.InputNames = cellstr(opt.InputNames);
        end
        if validate.list(opt.OutputNames)
            opt.OutputNames = cellstr(opt.OutputNames);
        end
        if iscellstr(opt.OutputNames) 
            if iscellstr(opt.OutputNames) && numel(opt.InputNames)==numel(opt.OutputNames)
                return
            end
        end
        thisError = { 'Databank:InconsistentInputOutputNames'
                      'When used together in databank.apply(~), '
                      'options InputNames= and OutputNames= '
                      'must be lists of the same size' };
        throw(exception.Base(thisError, 'error'));
    end%
end%

