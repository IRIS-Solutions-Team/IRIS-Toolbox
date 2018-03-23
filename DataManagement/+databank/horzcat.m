function outputDatabank = horzcat(varargin)

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('databank/horzcat');
    INPUT_PARSER.addRequired('DatabanksToCombine', @(x) ~isempty(x) && all(cellfun(@isstruct, x)));
end

INPUT_PARSER.parse(varargin);

%--------------------------------------------------------------------------

if nargin==1
    outputDatabank = varargin{1};
    return
end

numberOfDatabanks = nargin;
namesOfFields = fieldnames(varargin{1});
numberOfFields = numel(namesOfFields);

outputDatabank = struct( );
for i = 1 : numberOfFields
    name = namesOfFields{i};
    outputDatabank.(name) = cell(1, numberOfDatabanks);
    for j = 1 : numberOfDatabanks
        outputDatabank.(name){j} = varargin{j}.(name);
    end
    outputDatabank.(name) = horzcat(outputDatabank.(name){:});
end

end
