function container = fromFred(fredSeriesID, varargin)
% DatafeedContainer.fromFred  Populate DatafeedContainer from FRED database

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

persistent inputParser 
if isempty(inputParser)
    inputParser = extend.InputParser('DataFeedContainer.fromFred');
    inputParser.addRequired('FredSeriesID', @(x) iscellstr(x) || ischar(x) || isa(x, 'string'));
    inputParser.addParameter('URL', 'https://research.stlouisfed.org/fred2/', @(x) ischar(x) || isa(x, 'string'));
end

inputParser.parse(fredSeriesID, varargin{:});
opt = inputParser.Results;

%--------------------------------------------------------------------------

if ~iscell(fredSeriesID)
    fredSeriesID = cellstr(fredSeriesID);
end
fredSeriesID = strtrim(fredSeriesID);

numSeries = numel(fredSeriesID);
container = DatafeedContainer(numSeries);
if numSeries==0
    return
end

fredSeriesID = unique(fredSeriesID, 'stable');
numSeries = numel(fredSeriesID);
namesSeries = struct( );
for i = 1 : numSeries
    pos = strfind(fredSeriesID{i}, '->');
    if isempty(pos)
        name = fredSeriesID{i};
    else
        pos = pos(1);
        name = strtrim(fredSeriesID{i}(pos+2:end));
        fredSeriesID{i} = strtrim(fredSeriesID{i}(1:pos-1));
    end
    namesSeries.(fredSeriesID{i}) = name;
end

c = fred(char(opt.URL));
dataStruct = fetch(c, fredSeriesID);
close(c);

unknownFrequencies = cell(1, 0);
for i = 1 : numSeries
    ithSeriesID = strtrim( dataStruct(i).SeriesID );
    ithName = namesSeries.(ithSeriesID);
    ithFrequencyString = regexp(dataStruct(i).Frequency, '\w+', 'match', 'once');
    ithFrequency = Frequency.fromString(ithFrequencyString);
    ithYmd = datevec(dataStruct(i).Data(:, 1));
    ithYmd = ithYmd(:, 1:3);
    ithData = dataStruct(i).Data(:, 2);
    ithColumnNames = strtrim( dataStruct(i).Title );
    ithUserData = rmfield( dataStruct(i), 'Data' );
    ith(container, i, ithName, ithFrequency, ithYmd, ithData, ithColumnNames, ithUserData);
end

end%

