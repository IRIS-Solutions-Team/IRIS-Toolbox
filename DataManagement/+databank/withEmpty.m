%{
% 
% # `databank.withEmpty` ^^(+databank)^^
% 
% {== Create databank with empty time series ==}
% 
% 
% ## Syntax
% 
%     outputDb = databank.withEmpty(names, ...)
% 
% 
% ## Input Arguments
% 
% __`names`__ [ char | cellstr | string ] 
% > 
% > List of names under which
% > new empty time series will be created.
% > 
% 
% ## Output Arguments
% 
% __`outputDb`__ [ struct ] 
% > 
% > Databank with the new empty time series
% > created or added.
% > 
% 
% ## Options
% 
% __`AddToDatabank=struct()`__ [ struct ] 
% > 
% > Add the new empty time series to this databank.
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


function outputDatabank = withEmpty(listOfNames)

persistent parser
if isempty(parser)
    parser = extend.InputParser('databank.withEmpty');
    parser.addRequired('ListOfNames', @(x) ischar(x) || iscellstr(x) || isa(x, 'string'));
    parser.addParameter('AddToDatabank', struct( ), @isstruct);
end
parser.parse(listOfNames);
opt = parser.Options;

if ~iscellstr(listOfNames)
    listOfNames = cellstr(listOfNames);
end

%--------------------------------------------------------------------------

SERIES = Series( );

outputDatabank = opt.AddToDatabank;
for i = 1 : numel(listOfNames)
    outputDatabank.(listOfNames{i}) = SERIES;
end

end%

