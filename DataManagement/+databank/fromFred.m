function outputDatabank = fromFred(fredSeriesID, varargin)
% fromFred  Import data from FRED, Federal Reserve Bank of St. Louis databank
%
% __Syntax__
%
%      OutputDatabank = databank.fromFred(FredSeriesID, ...)
%
%
% __Input Arguments__
%
% * `FredSeriesID` [ cellstr | string ] - FRED Series IDs for requested
% data (not case sensitive).
%
%
% __Output Arguments__
%
% * `OutputDatabank` [ struct ] - Databank containing imported FRED series.
%
%
% __Options__
%
% * `AddToDatabank=struct( )` [ struct ] - Databank to which the data
% will be added.
%
% * `URL='https://research.stlouisfed.org/fred2/'` [ char | string ] - URL
% for the databank.
%
%
% __Description__
%
% Federal Reserve Economic Data, FRED (https://fred.stlouisfed.org/) is an
% online databank consisting of more than 385, 000 economic data time
% series from 80 national, international, public, and private sources.  The
% `databank.fromFred( )` function provides access to those databanks with
% IRIS.
%
% This function requires the Datafeed Toolbox.
%
%
% __Example__
%
%     d = databank.fromFred({'GDP', 'PCEC', 'FPI'})
%  
%     d = 
%       struct with fields:
%     
%          GDP: [281x1 Series]
%         PCEC: [281x1 Series]
%          FPI: [281x1 Series]
% 

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('databank.fromFred');
    inputParser.KeepUnmatched = true;
    inputParser.addRequired('FredSeriesID', @(x) ischar(x) || iscellstr(x) || isa(x, 'string'));
    inputParser.addParameter('AddToDatabank', struct( ), @isstruct);
end
inputParser.parse(fredSeriesID, varargin{:});
opt = inputParser.Options;
unmatched = inputParser.UnmatchedInCell;

%--------------------------------------------------------------------------

container = DatafeedContainer.fromFred(fredSeriesID, unmatched{:});
outputDatabank = export(container, opt.AddToDatabank);

end
