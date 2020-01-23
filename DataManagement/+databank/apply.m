function [outputDatabank, appliedToNames, newNames] = apply(func, inputDatabank, varargin)
% apply  Apply function to selection of databank fields
%{
% ## Syntax ##
%
%     [outputDatabank, appliedToNames, newNames] = apply(function, inputDatabank, ...) 
%
% 
% ## Input Arguments ##
%
% __`function`__ [ function_handle ] - 
% Function (function handle) that will be applied to the selected fields of
% the `inputDatabank`.
%
% __`inputDatabank`__ [ struct | Dictionary ] -
% Input databank to whose fields the `function` will be applied.
%
%
% ## Output Arguments ##
%
% __`outputDatabank`__ [ struct | Dictionary ] - 
% Output databank created from the `inputDatabank` with new fields or some
% fields modified.
%
% __`appliedToNames`__ [ cellstr | string ] -
% List of names to which the `function` has been actually applied.
%
% __`newNames`__ [ cellstr | string ] -
% List of names under which the results are stored in the `outputDatabank`.
%
%
% ## Options ##
%
% __`StartsWith=""`__ [ char | string ] -
% Apply the `function` to fields whose names start with this string.
%
% __`EndsWith=""`__ [ char | string ] -
% Apply the `function` to fields whose names end with this string.
%
% __`RemoveStart=false`__ [ `true` | `false` ] -
% If option `StartsWith=` was used, a new field will be created after the
% `function` has been applied with its named derived from the original name
% by removing the start of the string.
%
% __`RemoveEnd=false`__ [ `true` | `false` ] -
% If option `EndsWith=` was used, a new field will be created after the
% `function` has been applied with its named derived from the original name
% by removing the end of the string.
%
% __`Prepend=""`__ [ char | string ] -
% A new field will be created after the `function` has been applied with
% its named derived from the original name by prepending this string to the
% beginning of the original field name.
% 
% __`Append=""`__ [ char | string ] -
% A new field will be created after the `function` has been applied with
% its named derived from the original name by appending this string to the
% end of the original field name.
%
% __`RemoveSource=false`__ [ `true` | `false` ] -
% Remove the source field from the `outputDatabank`; the source field is
% the `inputDatabank` on which the `function` was run to create a new
% field.
%
% __`InputNames=@all`__ [ `@all` | cellstr | string ] -
% List of databank field names to which the name selection procedure will
% be reduced.
%
% __`OutputNames=@auto`__ [ `@auto` | cellstr | string ] -
% New names for output databank fields.
%
%
% ## Description ##
%
%
% ## Example ##
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
% ## Example ##
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

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

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
    pp.addParameter({'InputNames', 'Names', 'Fields'}, @all, @(x) isequal(x, @all) || validate.list(x));
    pp.addParameter('OutputNames', @auto, @(x) isequal(x, @auto) || validate.list(x));
    pp.addParameter('AddToDatabank', @auto, @(x) isequal(x, @auto) || validate.databank(x));
end
pp.parse(func, inputDatabank, varargin{:});
opt = pp.Options;

if ~isequal(opt.InputNames, @all)
    opt.InputNames = cellstr(opt.InputNames);
end

opt.HasPrefix = char(opt.HasPrefix);
opt.HasSuffix = char(opt.HasSuffix);
opt.AddPrefix = char(opt.AddPrefix);
opt.AddSuffix = char(opt.AddSuffix);

hereCheckInputOutputNames( );

%--------------------------------------------------------------------------

if isa(inputDatabank, 'Dictionary')
    namesFields = cellstr(keys(inputDatabank));
elseif isstruct(inputDatabank)
    namesFields = fieldnames(inputDatabank);
end

numFields = numel(namesFields);
newNames = repmat({''}, size(namesFields));

lenHasPrefix = length(opt.HasPrefix);
lenHasSuffix = length(opt.HasSuffix);

outputDatabank = opt.AddToDatabank;
if isequal(outputDatabank, @auto)
    outputDatabank = inputDatabank;
end

inxApplied = false(1, numFields);
inxToRemove = false(1, numFields);
for i = 1 : numFields
    name__ = namesFields{i};
    if ~isequal(opt.InputNames, @all) && ~any(strcmpi(name__, opt.InputNames))
       continue
    end 
    if ~isempty(opt.HasPrefix) && ~strncmpi(name__, opt.HasPrefix, lenHasPrefix)
        continue
    end
    if ~isempty(opt.HasSuffix) && ~strncmpi(fliplr(name__), fliplr(opt.HasSuffix), lenHasSuffix)
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
            newName__(1:lenHasPrefix) = '';
        end
        if opt.RemoveSuffix
            newName__(end-lenHasSuffix+1:end) = '';
        end
        if ~isempty(opt.AddPrefix)
            newName__ = [opt.AddPrefix, newName__];
        end
        if ~isempty(opt.AddSuffix)
            newName__ = [newName__, opt.AddSuffix];
        end
    end
    newNames{i} = newName__;

    field__ = inputDatabank.(name__);
    if ~isempty(func)
        field__ = func(field__);
    end
    outputDatabank.(newName__) = field__;
    inxToRemove(i) = opt.RemoveSource && ~strcmp(name__, newName__);
end

if any(inxToRemove)
    outputDatabank = rmfield(outputDatabank, namesFields(inxToRemove));
end

appliedToNames = namesFields(inxApplied);
newNames = newNames(inxApplied);

return


    function hereCheckInputOutputNames( )
        if isequal(opt.OutputNames, @auto)
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

