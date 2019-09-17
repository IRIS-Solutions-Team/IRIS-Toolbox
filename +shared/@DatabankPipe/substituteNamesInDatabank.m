function names = substituteNamesInDatabank(this, names)
% substituteNamesInDatabank  Replace model names with databank names
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('DatabankPipe.substituteNamesInDatabank');
    addRequired(parser, 'DatabankPipe', @(x) isa(x, 'shared.DatabankPipe'));
    addRequired(parser, 'Names', @validate.list);
end
parse(parser, this, names);

if isempty(this.NamesInDatabank)
    return
end

if isstruct(this.NamesInDatabank) && isempty(fieldnames(this.NamesInDatabank))
    return
end

%--------------------------------------------------------------------------

outputClass = class(names);
names = cellstr(names);
for i = 1 : numel(names)
    if isfield(this.NamesInDatabank, names{i})
        names{i} = char(getfield(this.NamesInDatabank, names{i}));
    end
end

if strcmp(outputClass, 'char')
    names = char(names);
elseif strcmp(outputClass, 'cell')
    names = cellstr(names);
elseif strcmp(outputClass, 'string')
    names = string(names);
end

end%

