function spy(inputDatabank, listSeries, startDate, endDate)
% spy  Visualize databank time series based on test condition
%{
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

startDate = double(startDate);
if nargin<4
    endDate = startDate(end);
    startDate = startDate(1);
end
endDate = double(endDate);

%--------------------------------------------------------------------------

if isequal(listSeries, @all)
    listSeries = fieldnames(inputDatabank);
end

if ~iscellstr(listSeries)
    listSeries = cellstr(listSeries);
end

if isempty(listSeries)
    return
end

numSeries = numel(listSeries);
inxToKeep = true(1, numSeries);
for i = 1 : numel(listSeries)
    name__ = listSeries{i};
    if ~isfield(inputDatabank, name__) ...
        || ~isa(inputDatabank.(name__), 'TimeSubscriptable')
        inxToKeep(i) = false;
    end
end
listSeries = listSeries(inxToKeep);

numSeries = numel(listSeries);
lenNames = cellfun(@length, listSeries, 'UniformOutput', false);
maxLengthName = max([lenNames{:}]);
numPeriods = round(endDate - startDate + 1);
textual.looseLine( );
for i = 1 : numSeries
    name__ = listSeries{i};
    fprintf('%*s ', maxLengthName, name__);
    series__ = inputDatabank.(name__);
    data = getDataFromTo(series__, startDate, endDate);
    data = data(:, :);
    inxNaN = all(isnan(data), 2);
    if all(inxNaN)
        fprintf('\n');
        continue
    end
    inxZeros = all(data==0, 2);
    spyString = repmat('.', 1, numPeriods);
    spyString(~inxNaN) = 'X';
    spyString(inxZeros) = 'O';
    posLastObs = find(~inxNaN, 1, 'Last');
    spyString(posLastObs+1:end) = '.';
    fprintf('%s\n', spyString);
end

textual.looseLine( );

end%

