function [outputDatabank, info] = simulate(this, inputDatabank, range, varargin)
% simulate  Simulate ExplanatoryEquation model
%{
% ## Syntax ##
%
%
%     [outputDb, info] = simulate(input, ...)
%
%
% ## Input Arguments ##
%
%
% __`input`__ [ | ]
% >
% Description
%
%
% ## Output Arguments ##
%
%
% __`output`__ [ | ]
% >
% Description
%
%
% ## Options ##
%
%
% __`OptionName=Default`__ [ | ]
% >
% Description
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------


% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 IRIS Solutions Team

% Invoke unit tests
%(
if nargin==2 && isequal(inputDatabank, '--test')
    outputDatabank = functiontests({ 
        @setupOnce
        @arxTest
        @transformTest
        @arxTestVariantsTest
        @arxWithResidualsTest
        @arxParametersTest    
        @arxSystemTest      
        @arxSystemVariantsTest      
        @arxSystemWithPrependTest  
        @blazerTest
        @allRaggedEdgeTest
        @someRaggedEdgeTest
        @runtimeIfTest
    });
    outputDatabank = reshape(outputDatabank, [ ], 1);
    return
end
%)


persistent pp
if isempty(pp)
    pp = extend.InputParser('ExplanatoryEquation.simulate');

    addRequired(pp, 'explanatoryEquation', @(x) isa(x, 'ExplanatoryEquation'));
    addRequired(pp, 'inputDatabank', @validate.databank);
    addRequired(pp, 'simulationRange', @DateWrapper.validateProperRangeInput);

    addParameter(pp, 'AddToDatabank', @auto, @(x) isequal(x, @auto) || isequal(x, [ ]) || validate.databank(x));
    addParameter(pp, {'AppendPostsample', 'AppendInput'}, false, @validate.logicalScalar);
    addParameter(pp, {'AppendPresample', 'PrependInput'}, false, @validate.logicalScalar);
    addParameter(pp, 'OutputType', 'struct', @validate.databankType);
    addParameter(pp, 'NaNParameters', 'Warning', @(x) validate.anyString(x, 'Error', 'Warning', 'Silent'));
    addParameter(pp, 'NaNSimulation', 'Warning', @(x) validate.anyString(x, 'Error', 'Warning', 'Silent'));
    addParameter(pp, 'RaggedEdge', @auto, @(x) isequal(x, @auto) || validate.logicalScalar(x));
    addParameter(pp, 'Blazer', cell.empty(1, 0), @iscell);
end
parse(pp, this, inputDatabank, range, varargin{:});
opt = pp.Options;

storeToDatabank = nargout>=1;

%--------------------------------------------------------------------------

if isempty(this)
    outputDatabank = inputDatabank;
    return
end

range = double(range);
numEquations = numel(this);
nv = countVariants(this);

%
% Create a DataBlock for all variables across all models; LHS variables are
% only needed when they appear on the RHS (tested within
% `getDataBlock(...)`
%
lhsRequired = false;
context = "for " + this(1).Context + " simulation";
dataBlock = getDataBlock(this, inputDatabank, range, lhsRequired, context);

numExtendedPeriods = dataBlock.NumOfExtendedPeriods;
numPages = dataBlock.NumOfPages;
numRuns = max(nv, numPages);
lhsNames = [this.LhsName];
baseRangeColumns = dataBlock.BaseRangeColumns;
extendedRange = DateWrapper(dataBlock.ExtendedRange);

hereExpandPagesIfNeeded( );

%
% Prepare runtime information
%
this = runtime(this, dataBlock, "simulate");

%
% Run blazer
% 
[blocks, ~, humanBlocks, dynamicStatus] = blazer(this, opt.Blazer{:});

if isequal(opt.RaggedEdge, @auto)
    raggedEdge = reshape([this.RaggedEdge], size(this));
else
    raggedEdge = repmat(opt.RaggedEdge, size(this));
end

for blk = 1 : numel(blocks)
    if numel(blocks{blk})==1
        eqn = blocks{blk};
        this__ = this(eqn);
        [plainData, lhs, rhs, res] = createModelData(this__, dataBlock);
        res(~isfinite(res)) = 0;
        if dynamicStatus(eqn)
            hereRunRecursive( );
        else
            hereRunOnce(baseRangeColumns);
        end
        updateDataBlock(this__, dataBlock, plainData);
    else
        for column = baseRangeColumns
            for eqn = blocks{blk}
                this__ = this(eqn);
                [plainData, lhs, rhs, res] = createModelData(this__, dataBlock);
                res(~isfinite(res)) = 0;
                hereRunOnce(column);
                updateDataBlock(this__, dataBlock, plainData);
            end
        end
    end
end

%
% Report equations with NaN or Inf parameters
%
inxNaNParameters = arrayfun(@(x) any(~isfinite(x.Parameters(:))), this);
if any(inxNaNParameters)
    hereReportNaNParameters( );
end

%
% Report LHS variables with NaN or Inf values
%
pos = textual.locate(lhsNames, dataBlock.Names);
reorder = [blocks{:}];
pos = pos(reorder);
inxNaNLhs = any(any(~isfinite(dataBlock.YXEPG(pos, baseRangeColumns, :)), 3), 2);
if any(inxNaNLhs)
    hereReportNaNSimulation( );
end

%
% Create output databank with LHS, RHS and residual names
%
if storeToDatabank
    namesToInclude = [this.LhsName];
    outputDatabank = createOutputDatabank(this, inputDatabank, dataBlock, namesToInclude, [ ], opt);
end

if nargout>=2
    info = struct( );
    info.Blocks = humanBlocks;
    info.DynamicStatus = dynamicStatus;
end

%
% Reset runtime information
%
this = runtime(this);

return


    function hereRunRecursive( )
        posLhs = this__.Dependent.Position;
        lhsPlainData = plainData(posLhs, :, :);
        for t = baseRangeColumns
            inxNaN = isnan(lhsPlainData(1, t, :));
            if raggedEdge(eqn) && all(~inxNaN)
                continue
            end
            if t>baseRangeColumns(1)
                date = getIth(extendedRange, t);
                rhs = updateOwnExplanatory(this__.Explanatory, rhs, plainData, t, date);
            end
            for v = 1 : numRuns
                if v<=nv
                    parameters__ = this__.Parameters(:, :, v);
                end
                if raggedEdge(eqn) && ~inxNaN(v)
                    continue
                end
                lhs(1, t, v) = parameters__*rhs(:, t, v);
            end
            lhs(1, t, :) = lhs(1, t, :) + res(:, t, :);
            plainData = updatePlainLhs(this__.Dependent, plainData, lhs, t);
        end
    end%




    function hereRunOnce(t)
        posLhs = this__.Dependent.Position;
        lhsPlainData = plainData(posLhs, :, :);
        for v = 1 : numRuns
            if v<=nv
                parameters__ = this__.Parameters(:, :, v);
            end
            t__ = t;
            if raggedEdge(eqn)
                if numel(t__)==1
                    if ~isnan(lhsPlainData(1, t__, v))
                        continue
                    end
                else
                    inx = false(1, numExtendedPeriods);
                    inx(t__) = true;
                    inx = inx & isnan(lhsPlainData(1, :, v));
                    if ~any(inx)
                        continue
                    end
                    t__ = inx;
                end
            end
            lhs(1, t__, v) = parameters__*rhs(:, t__, v);
            lhs(1, t__, v) = lhs(1, t__, v) + res(:, t__, v);
        end
        plainData = updatePlainLhs(this__.Dependent, plainData, lhs, baseRangeColumns);
    end%




    function hereExpandPagesIfNeeded( )
        if numPages==1 && nv>1
            dataBlock.YXEPG = repmat(dataBlock.YXEPG, 1, 1, nv);
            return
        elseif nv==1
            return
        elseif numPages~=nv
            thisError = [ 
                "ExplanatoryEquation:InconsistentPagesAndVariangs"
                "The number of data pages and the number of ExplanatoryEquation "
                "parameter variants need to be identical unless one of them is 1." 
            ];
            throw(exception.Base(thisError, 'error'));
        end
    end%




    function hereReportNaNParameters( )
        report = cellstr(lhsNames(inxNaNParameters));
        thisWarning  = [ 
            "ExplanatoryEquation:MissingObservationInSimulationRange"
            "Some Parameters are NaN or Inf in the ExplanatoryEquation object"
            "for this LHS variables: %s" 
        ];
        throw(exception.Base(thisWarning, opt.NaNParameters), report{:});
    end%




    function hereReportNaNSimulation( )
        report = cellstr(dataBlock.Names(pos(inxNaNLhs)));
        thisWarning  = [ 
            "ExplanatoryEquation:MissingObservationInSimulationRange"
            "Simulation of an ExplanatoryEquation object resulted "
            "in NaN or Inf values in this LHS variable: %s" 
        ];
        throw(exception.Base(thisWarning, opt.NaNSimulation), report{:});
    end%
end%




%
% Unit Tests 
%
%(
function setupOnce(testCase)
    m1 = ExplanatoryEquation.fromString("x = 0.8*x{-1} + (1-0.8)*c");
    m2 = ExplanatoryEquation.fromString("a = b + ?*(a{-1} - b) + ?");
    m3 = ExplanatoryEquation.fromString("z = x + a{-1}");
    m4 = ExplanatoryEquation.fromString("difflog(w) = 0.3*log(5/w{-1})");
    m5 = ExplanatoryEquation.fromString("c = y");
    startDate = numeric.qq(2001,1);
    endDate = numeric.qq(2010, 4);
    range = DateWrapper.roundColon(startDate, endDate);
    db = struct( );
    db.x = Series(DateWrapper.roundPlus(startDate, -1), 0);
    db.y = Series(range, @rand)*0.5 + 5;
    db.c = db.y;
    db.a = Series(DateWrapper.roundPlus(startDate, -1), 0);
    db.b = Series(range, @rand)*0.5 + 5;
    db.w = Series(DateWrapper.roundPlus(startDate, -1), 0.5+rand(1, 3)*10);
    testCase.TestData.Model1 = m1;
    testCase.TestData.Model2 = m2;
    testCase.TestData.Model3 = m3;
    testCase.TestData.Model4 = m4;
    testCase.TestData.Model5 = m5;
    testCase.TestData.Range = range;
    testCase.TestData.Databank = db;
end%


function arxTest(testCase)
    m1 = testCase.TestData.Model1;
    db = testCase.TestData.Databank;
    range = testCase.TestData.Range;
    s = simulate(m1, db, range);
    exp = db.x;
    for t = range
        exp(t) = 0.8*exp(t-1) + (1-0.8)*db.y(t);
    end
    assertEqual(testCase, s.x.Data, exp.Data, 'AbsTol', 1e-12);
    assertEqual(testCase, sort(fieldnames(db)), sort(setdiff(fieldnames(s), 'res_x')));
    assertEqual(testCase, s.w.Data, db.w.Data);
end%


function transformTest(testCase)
    m4 = testCase.TestData.Model4;
    db = testCase.TestData.Databank;
    range = testCase.TestData.Range;
    s = simulate(m4, db, range);
    for i = 1 : 3
        exp_w = db.w{:, i};
        for t = range
            temp = 0.3*log(5/exp_w(t-1));
            exp_w(t) = exp_w(t-1)*exp(temp);
        end
        assertEqual(testCase, s.w.Data(:, i), exp_w.Data, 'AbsTol', 1e-12);
    end
end%


function arxTestVariantsTest(testCase)
    m2 = testCase.TestData.Model2;
    m2 = alter(m2, 3);
    rho = rand(1, 1, 3);
    m2.FreeParameters = [rho, zeros(1, 1, 3)];
    db = testCase.TestData.Databank;
    db.a = [db.a, db.a+1, db.a+2];
    range = testCase.TestData.Range;
    s = simulate(m2, db, range);
    for i = 1 : 3
        exp = db.a{:, i};
        for t = range
            exp(t) = rho(i)*exp(t-1) + (1-rho(i))*db.b(t);
        end
        assertEqual(testCase, s.a.Data(:, i), exp.Data, 'AbsTol', 1e-12);
    end
end%


function arxWithResidualsTest(testCase)
    m1 = testCase.TestData.Model1;
    db = testCase.TestData.Databank;
    range = testCase.TestData.Range;
    db.res_x = Series(range(3:end-3), @randn)/10;
    s = simulate(m1, db, range);
    exp = db.x;
    for t = range
        exp(t) = 0.8*exp(t-1) + (1-0.8)*db.y(t);
        res_x = db.res_x(t);
        if isfinite(res_x)
            exp(t) = exp(t) + res_x;
        end
    end
    assertEqual(testCase, s.x.Data, exp.Data, 'AbsTol', 1e-12);
end%


function arxParametersTest(testCase)
    m2 = testCase.TestData.Model2;
    rho = rand(1);
    m2.Parameters([1, 2]) = [rho, 0];
    db = testCase.TestData.Databank;
    range = testCase.TestData.Range;
    s = simulate(m2, db, range);
    exp_a = db.a;
    for t = range
        exp_a(t) = rho*exp_a(t-1) + (1-rho)*db.b(t);
    end
    assertEqual(testCase, s.a.Data, exp_a.Data, 'AbsTol', 1e-12);
end%


function arxSystemTest(testCase)
    m = [ testCase.TestData.Model1
          testCase.TestData.Model2
          testCase.TestData.Model3 ];
    rho = rand(1);
    m(2).Parameters([1, 2]) = [rho, 0];
    db = testCase.TestData.Databank;
    range = testCase.TestData.Range;
    s = simulate(m, db, range);
    exp_z = s.x{range} + s.a{-1}{range};
    assertEqual(testCase, s.z.Data, exp_z.Data, 'AbsTol', 1e-12);
end%


function arxSystemVariantsTest(testCase)
    m = [ testCase.TestData.Model1
          testCase.TestData.Model2
          testCase.TestData.Model3 ];
    m = alter(m, 3);
    rho = rand(1, 1, 3);
    m(2).FreeParameters = [rho, zeros(1, 1, 3)];
    db = testCase.TestData.Databank;
    range = testCase.TestData.Range;
    s = simulate(m, db, range);
    exp_z = s.x{range} + s.a{-1}{range};
    assertEqual(testCase, s.z.Data, exp_z.Data, 'AbsTol', 1e-12);
end%


function arxSystemWithPrependTest(testCase)
    m = [ testCase.TestData.Model1
          testCase.TestData.Model2
          testCase.TestData.Model3 ];
    rho = rand(1);
    m(2).FreeParameters = [rho, 0];
    range = testCase.TestData.Range;
    db = testCase.TestData.Databank;
    db.x(range(1)+(-10:-2)) = rand(9, 1);
    s = simulate(m, db, range, 'PrependInput=', true);
    exp_z = s.x{range} + s.a{-1}{range};
    assertEqual(testCase, s.z.Data, exp_z.Data, 'AbsTol', 1e-12);
    assertEqual(testCase, double(s.x.Start), range(1)-10);
    assertEqual(testCase, s.x(range(1)+(-10:-2)), db.x(range(1)+(-10:-2)));
end%


function blazerTest(testCase)
    xq = ExplanatoryEquation.fromString([
        "x = y{-1} + z{-1}"
        "y = x{-1}"
        "a = b{-1} + a{-2}"
        "b = a{-1} + b{-2}"
        "z = a"
    ]);
    db = struct( );
    db.a = Series(-1:1000, @rand);
    db.b = Series(-1:1000, @rand);
    db.x = Series(0, rand);
    db.y = Series(0, rand);
    db.z = Series(0, rand);
    [simDb1, info1] = simulate(xq, db, 1:1000);
    [simDb2, info2] = simulate(xq, db, 1:1000, 'Blazer=', {'Reorder=', false});
    [simDb3, info3] = simulate(xq([1,3,4,5,2]), db, 1:1000);
    for i = reshape(string(fieldnames(simDb1)), 1, [ ]);
        assertEqual(testCase, simDb1.(i).Data, simDb2.(i).Data, 'AbsTol', 1e-12);
        assertEqual(testCase, simDb1.(i).Data, simDb3.(i).Data, 'AbsTol', 1e-12);
    end
end%


function allRaggedEdgeTest(testCase)
    xq = ExplanatoryEquation.fromString([
        "a = b{-1};"
        "b = c{-1};"
        "c = d{-1};"
    ]);
    db = struct( );
    db.d = Series(0:10, 0:10);
    db.c = Series(0:8, 0:10:80);
    db.b = Series(0:6, 0:100:600);
    simDb1 = simulate(xq, db, 1:10);
    simDb2 = simulate(xq, db, 1:10, 'RaggedEdge=', true);

    assertEqual(testCase, simDb1.c(1:10), db.d{-1}(1:10), 'AbsTol', 1e-14);
    assertEqual(testCase, simDb2.c(1:8), db.c(1:8), 'AbsTol', 1e-14);
    assertEqual(testCase, simDb2.c(9:10), db.d{-1}(9:10), 'AbsTol', 1e-14);

    assertEqual(testCase, simDb1.b(1:10), simDb1.c{-1}(1:10), 'AbsTol', 1e-14);
    assertEqual(testCase, simDb2.b(1:6), db.b(1:6), 'AbsTol', 1e-14);
    assertEqual(testCase, simDb2.b(7:10), simDb2.c{-1}(7:10), 'AbsTol', 1e-14);

    assertEqual(testCase, simDb1.a(1:10), simDb1.b{-1}(1:10), 'AbsTol', 1e-14);
    assertEqual(testCase, simDb2.a(1:10), simDb2.b{-1}(1:10), 'AbsTol', 1e-14);
end%


function someRaggedEdgeTest(testCase)
    xq = ExplanatoryEquation.fromString([
        "a = b{-1};"
        ":exogenous b = c{-1};"
        "c = d{-1};"
    ]);
    db = struct( );
    db.d = Series(0:10, 0:10);
    db.c = Series(0:8, 0:10:80);
    db.b = Series(0:6, 0:100:600);
    simDb1 = simulate(xq, db, 1:10, 'RaggedEdge=', false);

    xq(hasAttribute(xq, ":exogenous")).RaggedEdge = true;
    simDb2 = simulate(xq, db, 1:10, 'RaggedEdge=', @auto);

    assertEqual(testCase, simDb1.c(1:10), db.d{-1}(1:10), 'AbsTol', 1e-14);
    assertEqual(testCase, simDb2.c(1:10), db.d{-1}(1:10), 'AbsTol', 1e-14);

    assertEqual(testCase, simDb1.b(1:10), simDb1.c{-1}(1:10), 'AbsTol', 1e-14);
    assertEqual(testCase, simDb2.b(1:6), db.b(1:6), 'AbsTol', 1e-14);
    assertEqual(testCase, simDb2.b(7:10), simDb2.c{-1}(7:10), 'AbsTol', 1e-14);

    assertEqual(testCase, simDb1.a(1:10), simDb1.b{-1}(1:10), 'AbsTol', 1e-14);
    assertEqual(testCase, simDb2.a(1:10), simDb2.b{-1}(1:10), 'AbsTol', 1e-14);
end%


function runtimeIfTest(testCase)
    xq = ExplanatoryEquation.fromString([
        "a = a{-1} + if__(date__,'==',qq(2001,4), 5, 0);"
        "b = b{-1} + if__(b{-1}, '<', 0, 1, 0);"
    ]);
    db = struct( );
    db.a = Series(qq(2000,4), 10);
    db.b = Series(qq(2000,4), -3);
    simDb = simulate(xq, db, qq(2001,1):qq(2004,4));
    exp_a = Series(qq(2000,4):qq(2004,4), 10);
    exp_a(qq(2001,4):end) = 15;
    assertEqual(testCase, simDb.a(:), exp_a(:), 'AbsTol', 1e-14);
    exp_b = Series(qq(2000,4):qq(2004,4), 0);
    exp_b(qq(2000,4):qq(2001,2)) = [-3;-2;-1];
    assertEqual(testCase, simDb.b(:), exp_b(:), 'AbsTol', 1e-14);
end%
%)
