% initializeLogStatus  Initialize log status of variables from !log-variables
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function this = initializeLogStatus(this, logNames, processorLhsNames)

if isa(logNames, 'Except')
    default = true;
    logNames = logNames.List;
elseif ischar(logNames) || iscellstr(logNames) || isstring(logNames)
    default = false;
else
    return
end

allNames = reshape(string(this.Name), 1, []);
logNames = unique(reshape(string(logNames), 1, [ ]));

% Names that can be on the !log-variables list:
% measurement, transition, exogenous variable exept ttrend
inxCanBeLog = getIndexByType(this, 1, 2, 5);
posTrendLine = locateTrendLine(this, NaN);
inxCanBeLog(posTrendLine) = false;
namesCanBeLog = unique([allNames(inxCanBeLog), processorLhsNames], 'stable');

inxValidLogNames = ismember(logNames, namesCanBeLog) | ismember(logNames, processorLhsNames);
if any(~inxValidLogNames)
    exception.error([
        "Model:InvalidLogName"
        "This is not a valid name to appear in the !log-variables section: %s "
    ], logNames(~inxValidLogNames));
end

this.IxLog(inxCanBeLog) = default;
inxSet = ismember(allNames, logNames);
this.IxLog(inxSet) = ~default;

end%




%
% Unit Tests
%
%{
##### SOURCE BEGIN #####
% saveAs=Quantity/initializeLogStatusUnitTest.m

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);

%% Test Default False

q = model.Quantity;
q.Name = ["a", "b", "c", "d", "ea", "eb", "g", "ttrend"];
q.Type = [1, 2, 2, 2, 3, 3, 5, 5];
q.IxLog = false(size(q.Name));
log = ["a", "b", "g"];
q = initializeLogStatus(q, log);
assertEqual(testCase, q.IxLog, [true, true, false, false, false, false, true, false]);


%% Test Default True

q = model.Quantity;
q.Name = ["a", "b", "c", "d", "ea", "eb", "g", "ttrend"];
q.Type = [1, 2, 2, 2, 3, 3, 5, 5];
q.IxLog = false(size(q.Name));
log = Except(["a", "b", "g"]);
q = initializeLogStatus(q, log);
assertEqual(testCase, q.IxLog, [false, false, true, true, false, false, false, false]);

##### SOURCE END #####
%}

