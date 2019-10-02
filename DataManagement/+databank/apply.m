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
% __`AddToStart=""`__ [ char | string ] -
% A new field will be created after the `function` has been applied with
% its named derived from the original name by adding this string to the
% beginning of the original field name.
% 
% __`AddToEnd=""`__ [ char | string ] -
% A new field will be created after the `function` has been applied with
% its named derived from the original name by adding this string to the
% end of the original field name.
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
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

persistent parser
if isempty(parser)
    parser = extend.InputParser('databank.apply');
    parser.addRequired('Function', @(x) isempty(x) || isa(x, 'function_handle'));
    parser.addRequired('InputDatabank', @validate.databank);
    parser.addParameter({'HasPrefix', 'StartsWith'}, '',  @(x) ischar(x) || (isa(x, 'string') && isscalar(x)));
    parser.addParameter({'HasSuffix', 'EndsWith'}, '',  @(x) ischar(x) || (isa(x, 'string') && isscalar(x)));
    parser.addParameter({'AddPrefix', 'AddToStart'}, '',  @(x) ischar(x) || (isa(x, 'string') && isscalar(x)));
    parser.addParameter({'AddSuffix', 'AddToEnd'}, '',  @(x) ischar(x) || (isa(x, 'string') && isscalar(x)));
    parser.addParameter({'RemovePrefix', 'RemoveStart'}, false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter({'RemoveSuffix', 'RemoveEnd'}, false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter({'List', 'Names', 'Fields'}, @all, @(x) isequal(x, @all) || ischar(x) || iscellstr(x) || isa(x, 'string'));
    parser.addParameter('AddToDatabank', @auto, @(x) isequal(x, @auto) || isstruct(x));
end
parser.parse(func, inputDatabank, varargin{:});
opt = parser.Options;

if ~isequal(opt.List, @all)
    opt.List = cellstr(opt.List);
end

opt.HasPrefix = char(opt.HasPrefix);
opt.HasSuffix = char(opt.HasSuffix);
opt.AddPrefix = char(opt.AddPrefix);
opt.AddSuffix = char(opt.AddSuffix);

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

inxApplied = false(size(namesFields));
for i = 1 : numFields
    ithName = namesFields{i};
    if ~isequal(opt.List, @all) && ~any(strcmpi(ithName, opt.List))
       continue
    end 
    if ~isempty(opt.HasPrefix) && ~strncmpi(ithName, opt.HasPrefix, lenHasPrefix)
        continue
    end
    if ~isempty(opt.HasSuffix) && ~strncmpi(fliplr(ithName), fliplr(opt.HasSuffix), lenHasSuffix)
        continue
    end
    inxApplied(i) = true;
    ithNewName = ithName;
    if opt.RemovePrefix
        ithNewName(1:lenHasPrefix) = '';
    end
    if opt.RemoveSuffix
        ithNewName(end-lenHasSuffix+1:end) = '';
    end
    if ~isempty(opt.AddPrefix)
        ithNewName = [opt.AddPrefix, ithNewName];
    end
    if ~isempty(opt.AddSuffix)
        ithNewName = [ithNewName, opt.AddSuffix];
    end
    newNames{i} = ithNewName;

    ithSeries = getfield(inputDatabank, ithName);
    if ~isempty(func)
        ithSeries = func(ithSeries);
    end
    outputDatabank = setfield(outputDatabank, ithNewName, ithSeries);
end

appliedToNames = namesFields(inxApplied);
newNames = newNames(inxApplied);

end%

