function [data, names, dates, dateTransform] = extractSeriesData(inputDb, names, dates) 

if isa(names, 'function_handle')
    names = databank.filterFields(inputDb, 'name', names, 'class', 'NumericTimeSubscriptable');
end
names = reshape(string(names), 1, [ ]);

if isa(inputDb, 'Dictionary')
    allSeries = arrayfun( ...
        @(n) locallyMustBeSeries(retrieve(inputDb, n), n), names ...
        , 'uniformOutput', false ...
    );
else
    allSeries = arrayfun( ...
        @(n) locallyMustBeSeries(inputDb.(n), n), names ...
        , 'uniformOutput', false ...
    );
end

[dates, dateTransform] = locallyResolveDates(dates);
data = cell(size(allSeries));
context = '';
[dates, data{:}] = getDataFromMultiple(dates, context, allSeries{:});
dates = reshape(double(dates), 1, []);

end%

%
% Local Functions
%

function [dates, dateTransform] = locallyResolveDates(dates)
    dateTransform = [ ];
    if isstring(dates)
        if startsWith(dates, 'head', 'ignoreCase', true)
            dateTransform = @head;
            dates = "unbalanced";
        elseif startsWith(dates, 'tail', 'ignoreCase', true)
            dateTransform = @tail;
            dates = "unbalanced";
        end
    end
end%

%
% Local Validators
%

function value = locallyMustBeSeries(value, name)
    if isa(value, 'NumericTimeSubscriptable')
        return
    end
    exception.error([
        "Databank:ExtractSeries"
        "This databank field is not a time series: %s"
    ], name);
end%




%
% Unit tests
%
%{
##### SOURCE BEGIN #####
% saveAs=databank/extractSeriesDataUnitTest.m

this = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);


% Set up once

db = struct();
db.x = Series();
db.y = Series(qq(2020,1), rand(20,1));
db.z = Series(qq(2020,1), rand(20,2));


%% Specify names and dates 

data = databank.backend.extractSeriesData(db, ["x", "y", "z"], qq(2020,1:4));
assertEqual(this, size(data{1}), [4, 1]);
assertEqual(this, isnan(data{1}), true(4, 1));
assertEqual(this, size(data{2}), [4, 1]);
assertEqual(this, size(data{3}), [4, 2]);


%% All dates, specify names 

data = databank.backend.extractSeriesData(db, ["x", "y", "z"], Inf);
assertEqual(this, size(data{1}), [20, 1]);
assertEqual(this, isnan(data{1}), true(20, 1));
assertEqual(this, size(data{2}), [20, 1]);
assertEqual(this, size(data{3}), [20, 2]);


%% All dates, all names 

data = databank.backend.extractSeriesData(db, @all, Inf);
assertEqual(this, size(data{1}), [20, 1]);
assertEqual(this, isnan(data{1}), true(20, 1));
assertEqual(this, size(data{2}), [20, 1]);
assertEqual(this, size(data{3}), [20, 2]);

##### SOURCE END #####
%}

