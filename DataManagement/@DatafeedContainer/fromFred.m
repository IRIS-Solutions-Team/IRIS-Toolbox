function container = fromFred(fredID, varargin)
% DatafeedContainer.fromFred  Populate DatafeedContainer from FRED database.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

persistent INPUT_PARSER 
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('feed/fred');
    INPUT_PARSER.addRequired('FredSeriesID', @(x) iscellstr(x) || ischar(x) || isa(x, 'string'));
    INPUT_PARSER.addParameter('URL', 'https://research.stlouisfed.org/fred2/', @(x) ischar(x) || isa(x, 'string'));
end

INPUT_PARSER.parse(fredID, varargin{:});
opt = INPUT_PARSER.Results;

%--------------------------------------------------------------------------

if ~iscell(fredID)
    fredID = cellstr(fredID);
end
numSeries = numel(fredID);
container = DatafeedContainer(numSeries);
if numSeries==0
    return
end

fredID = unique(fredID, 'stable');

c = fred(char(opt.URL));
dataStruct = fetch(c, fredID);
close(c);

unknownFrequencies = cell(1, 0);
for i = 1 : numSeries
    ithName = strtrim( dataStruct(i).SeriesID );
    ithFrequencyString = regexp(dataStruct(i).Frequency, '\w+', 'match', 'once');
    ithFrequency = Frequency.fromString(ithFrequencyString);
    ithYmd = datevec(dataStruct(i).Data(:, 1));
    ithYmd = ithYmd(:, 1:3);
    ithData = dataStruct(i).Data(:, 2);
    ithColumnNames = strtrim( dataStruct(i).Title );
    ithUserData = rmfield( dataStruct(i), 'Data' );
    ith(container, i, ithName, ithFrequency, ithYmd, ithData, ithColumnNames, ithUserData);
end

end

