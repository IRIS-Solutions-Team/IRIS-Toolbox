function outputDatabank = residuals(this, inputDatabank, range, varargin)
% residuals  Evaluate residuals from ExplanatoryEquation for currently assigned parameters
%{
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 IRIS Solutions Team

% Invoke unit tests
%(
if nargin==2 && isequal(inputDatabank, '--test')
    outputDatabank = functiontests({ 
        @setupOnce
        @residualsTest
    });
    outputDatabank = reshape(outputDatabank, [ ], 1);
    return
end
%)

%--------------------------------------------------------------------------

[~, outputDatabank] = regress(this, inputDatabank, range, varargin{:}, 'FixParameters=', true);

end%




%
% Unit Tests
%
%(
function setupOnce(testCase)
    m1 = ExplanatoryEquation.fromString('x = ? + ?*x{-1} + ?*y');
    startDate = qq(2001,1);
    endDate = qq(2010, 4);
    baseRange = startDate:endDate;
    db1 = struct( );
    db1.x = Series(startDate-10:endDate+10, cumsum(randn(60,1)));
    db1.y = Series(startDate:endDate, cumsum(randn(40,1)));
    testCase.TestData.Model1 = m1;
    testCase.TestData.Databank1 = db1;
    testCase.TestData.BaseRange = baseRange;
end%


function residualsTest(testCase)
    m1 = testCase.TestData.Model1;
    db1 = testCase.TestData.Databank1;
    baseRange = testCase.TestData.BaseRange;
    [est1, outputDb1] = regress(m1, db1, baseRange);
    outputDb2 = residuals(est1, db1, baseRange);
    [est2, outputDb3] = regress(est1, db1, baseRange, 'FixParameters=', true);
    assertEqual(testCase, outputDb1.res_x.Data, outputDb2.res_x.Data);
    assertEqual(testCase, outputDb1.res_x.Data, outputDb3.res_x.Data);
    assertEqual(testCase, est1, est2);
end%
%)

