function this = initializeLogStatus(this, log)
% initializeLogStatus  Initialize log status of Explanatory equations from
% log-variables section of model file
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

if isa(log, 'Except')
    default = true;
    log = reshape(string(log.List), 1, [ ]);
else
    default = false;
    log = reshape(string(log), 1, [ ]);
end

numThis = numel(this);
for i = 1 : numThis
    inx = this(i).LhsName==log;
    if any(inx)
        this(i).LogStatus = ~default;
    else
        this(i).LogStatus = default;
    end
end

end%




%
% Unit Tests
%{
##### SOURCE BEGIN #####
% saveAs=Explanatory/initializeLogStatusUnitTest.m

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);
expy = Explanatory.fromString(["a=x", "b=y", "c=z"]);


%% Test Default True

    log = ["a", "c"];
    expy = initializeLogStatus(expy, log);
    assertEqual(testCase, collectLogStatus(expy), [true, false, true]);


%% Test Default False

    log = Except(["a", "b"]);
    expy = initializeLogStatus(expy, log);
    assertEqual(testCase, collectLogStatus(expy), [false, false, true]);

##### SOURCE END #####
%}

