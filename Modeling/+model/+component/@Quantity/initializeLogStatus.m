function this = initializeLogStatus(this, log)
% initializeLogStatus  Initialize log status of variables from
% log-variables section
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

TYPE = @int8;

%--------------------------------------------------------------------------

if isa(log, 'Except')
    default = true;
    log = log.List;
elseif ischar(log) || iscellstr(log) || isstring(log)
    default = false;
else
    return
end

log = unique(reshape(string(log), 1, [ ]));

inxCanBeLog = getIndexByType(this, TYPE(1), TYPE(2), TYPE(5));

% Exclude ttrend
inxTimeTrend = strcmp(this.Name, model.component.Quantity.RESERVED_NAME_TTREND);
inxCanBeLog(inxTimeTrend) = false;

this.IxLog(inxCanBeLog) = default;

ell = lookup(this, cellstr(log));
inxSet = ell.InxName & inxCanBeLog;
this.IxLog(inxSet) = ~default;

log = setdiff(log, this.Name(inxSet));
if ~isempty(log)
    thisError = [
        "Model:InvalidLogName"
        "This is an invalid name to appear in the !log-variables section: %s "
    ];
    throw(exception.Base(thisError, 'error'), log);
end

end%




% Unit Tests
%{
##### SOURCE BEGIN #####
% saveAs=Quantity/initializeLogStatusUnitTest.m

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);
TYPE = @int8;


%% Test Default False

q = model.component.Quantity;
q.Name = ["a", "b", "c", "d", "ea", "eb", "g", "ttrend"]
q.Type = TYPE([1, 2, 2, 2, 3, 3, 5, 5]);
q.IxLog = false(size(q.Name));
log = ["a", "b", "g"];
q = initializeLogStatus(q, log);
assertEqual(testCase, q.IxLog, [true, true, false, false, false, false, true, false]);


%% Test Default True

q = model.component.Quantity;
q.Name = ["a", "b", "c", "d", "ea", "eb", "g", "ttrend"]
q.Type = TYPE([1, 2, 2, 2, 3, 3, 5, 5]);
q.IxLog = false(size(q.Name));
log = Except(["a", "b", "g"]);
q = initializeLogStatus(q, log);
assertEqual(testCase, q.IxLog, [false, false, true, true, false, false, false, false]);

##### SOURCE END #####
%}

