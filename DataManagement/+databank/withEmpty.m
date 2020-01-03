function outputDatabank = withEmpty(listOfNames)
% databank.withEmpty  Create databank with empty time series
%
% __Syntax__
%
%     outputDatabank = databank.withEmpty(listOfNames, ...)
%
%
% __Input Arguments__
%
% * `listOfNames` [ char | cellstr | string ] - List of names under which
% new empty time series will be created.
%
%
% __Output Arguments__
%
% * `outputDatabank` [ struct ] - Databank with the new empty time series
% created or added.
%
%
% __Options__
%
% * `AddToDatabank=struct( )` [ struct ] - Add the new empty time series to
% this databank.
%
%
% __Description__
%
%
% __Example__
%
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team.

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

