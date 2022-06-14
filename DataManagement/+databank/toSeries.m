% toSeries  Consolidate multiple time series into one time series
%{
% Syntax
%--------------------------------------------------------------------------
%
%     outputSeries = toSeries(inputDb, ~names, ~dates, ~column)
%
%
% Input Arguments
%--------------------------------------------------------------------------
%
% __``__ [ ]
%
%>    
%
%
% Output Arguments
%--------------------------------------------------------------------------
%
% __``__ [ ]
%
%>    
%
%
% Options
%--------------------------------------------------------------------------
%
%
% __`=`__ [ | ]
%
%>    
%
%
% Description
%--------------------------------------------------------------------------
%
%
% Example
%--------------------------------------------------------------------------
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team


% >=R2019b
%{
function [outputSeries, names, dates] = toSeries(inputDb, names, dates, columns)

arguments
    inputDb (1, 1) {validate.databank(inputDb)}

    names {locallyValidateNames(names)} = @all
    dates {locallyValidateDates(dates)} = @all
    columns (1, :) {mustBeInteger, mustBePositive} = 1
end
%}
% >=R2019b


% <=R2019a
%(
function [outputSeries, names, dates] = toSeries(inputDb, varargin)

persistent ip
if isempty(ip)
    ip = inputParser(); 
    addOptional(ip, "names", @all);
    addOptional(ip, "dates", @all);
    addOptional(ip, 'columns', 1);
end
parse(ip, varargin{:});
names = ip.Results.names;
dates = ip.Results.dates;
columns = ip.Results.columns;
%)
% <=R2019a


if isequal(names, @all)
    names = keys(inputDb);
    inxSeries = cellfun(@(n) isa(inputDb.(n), "TimeSubscriptable"), names);
    names = names(inxSeries);
else
    names = reshape(string(names), 1, [ ]);
end

if isempty(names)
    exception.error([
        "Datebank:EmptyNameList"
        "The list of time series names requested resolved to an empty array."
    ]);
end

if isequal(dates, @all) || isequal(dates, Inf)
    dates = databank.range(inputDb, "NameList", names);
    if iscell(dates)
        exception.error([
            "Databank:MultipleFrequencies"
            "Time series requested include multiple date frequencies. "
            "Cannot determine the output dates. "
        ]);
    elseif isempty(dates)
        exception.error([
            "Databank:UndeterminedFrequency"
            "None of the time series requested has proper date frequency. "
            "Cannot determine the output dates. "
        ]);
    end
end

[outputArray, ~, ~, headers] = databank.toArray(inputDb, names, dates, columns);
outputSeries = Series(dates, outputArray);
outputSeries.Headers = headers;

end%

%
% Local Validators
%

function locallyValidateNames(input)
    %(
    if isequal(input, @all) || isstring(input) || ischar(input) || iscellstr(input)
        return
    end
    error("Validation:Failed", "Input value must be an array of strings");
    %)
end%


function locallyValidateDates(input)
    %(
    if isequal(input, @all) || isequal(input, Inf) || validate.properDates(input)
        return
    end
    error("Validation:Failed", "Input value must be @all or an array of proper dates");
    %)
end%




%
% Unit Tests
%
%{
##### SOURCE BEGIN #####
% saveAs=databank/toSeriesUnitTest.m

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);

% Set up Once
    d1 = struct();
    d1.a = Series(qq(1), rand(40,1));
    d1.b = Series(qq(2), rand(40,1));
    d1.c = Series(mm(1), rand(120,1));
    d1.d = Series( );
    d1.e = Series(qq(1), rand(40,2,3));
    d1.f = Series(qq(2), rand(40,2,3));
    d1.x = "a";
    d1.y = 1;
    d2 = struct();
    d2.a = d1.a;
    d2.b = d1.b;
    d2.x = d1.x;
    d2.y = d1.y;


%% Test Plain Vanilla
    x = databank.toSeries(d1, ["a", "b"]);
    y = [d1.a, d1.b];
    assertEqual(testCase, x.Data, y.Data);


%% Test All Names
    x = databank.toSeries(d2);
    y = [d2.a, d2.b];
    assertEqual(testCase, x.Data, y.Data);


%% Test User Dates
    x = databank.toSeries(d1, ["a", "b"], qq(1,1:10));
    y = [d1.a{qq(1,1:10)}, d1.b{qq(1,1:10)}];
    assertEqual(testCase, x.Data, y.Data);


%% Test Multidimensional Default Column
    x = databank.toSeries(d1, ["e", "f"]);
    y = [d1.e{:,1}, d1.f{:,1}];
    assertEqual(testCase, x.Data, y.Data);


%% Test Multidimensional User Column
    x = databank.toSeries(d1, ["e", "f"], @all, 3);
    y = [d1.e{:,1,2}, d1.f{:,1,2}];
    assertEqual(testCase, x.Data, y.Data);


%% Error Multiple Frequencies
    isError = false;
    try
        x = databank.toSeries(d1);
    catch
        isError = true;
    end
    assertTrue(testCase, isError);


%% Error Empty Series
    isError = false;
    try
        x = databank.toSeries(d1, "d");
    catch
        isError = true;
    end
    assertTrue(testCase, isError);

##### SOURCE END #####
%}

