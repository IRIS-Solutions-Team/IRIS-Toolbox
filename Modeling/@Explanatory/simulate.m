function [outputData, info] = simulate(this, inputData, range, varargin)
%{
% simulate  Simulate Explanatory equation or array of equations
%
% Syntax
%--------------------------------------------------------------------------
%
%     [outputData, info] = simulate(expy, inputData, range, ...)
%
%
% Input Arguments
%--------------------------------------------------------------------------
%
% __`expy`__ [ Explanatory ]
%
%     Description
%
%
% Output Arguments
%--------------------------------------------------------------------------
%
% __`output`__ [ | ]
%
%     Description
%
%
% Options
%--------------------------------------------------------------------------
%
% __`OptionName=Default`__ [ | ]
%
%     Description
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
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('Explanatory/simulate');

    addRequired(pp, 'explanatory', @(x) isa(x, 'Explanatory'));
    addRequired(pp, 'inputData', @(x) validate.databank(x) || isa(x, 'shared.DataBlock'));
    addRequired(pp, 'simulationRange', @DateWrapper.validateProperRangeInput);

    addParameter(pp, 'AddToDatabank', @auto, @(x) isequal(x, @auto) || isequal(x, [ ]) || validate.databank(x));
    addParameter(pp, {'AppendPostsample', 'AppendInput'}, false, @validate.logicalScalar);
    addParameter(pp, {'AppendPresample', 'PrependInput'}, false, @validate.logicalScalar);
    addParameter(pp, 'OutputType', 'struct', @validate.databankType);
    addParameter(pp, 'NaNParameters', 'Warning', @(x) validate.anyString(x, 'Error', 'Warning', 'Silent'));
    addParameter(pp, 'NaNSimulation', 'Warning', @(x) validate.anyString(x, 'Error', 'Warning', 'Silent'));
    addParameter(pp, 'Plan', [ ], @(x) isempty(x) || isa(x, 'Plan'));
    addParameter(pp, 'Blazer', cell.empty(1, 0), @iscell);
end
%)
opt = parse(pp, this, inputData, range, varargin{:});

storeToDatabank = nargout>=1 && validate.databank(inputData);

%--------------------------------------------------------------------------

if isempty(this)
    outputData = inputData;
    info = struct( );
    info.Blocks = cell.empty(1, 0);
    info.DynamicStatus = false;
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
outputData = getDataBlock(this, inputData, range, lhsRequired, context);
numExtendedPeriods = outputData.NumOfExtendedPeriods;
numPages = outputData.NumOfPages;
numRuns = max(nv, numPages);
lhsNames = [this.LhsName];
baseRangeColumns = outputData.BaseRangeColumns;
extendedRange = DateWrapper(outputData.ExtendedRange);


%
% Create struct with controls
%
if validate.databank(inputData)
    controls = assignControls(this, inputData);
else
    controls = struct( );
end


%
% Extract exogenized points from the Plan
%
[isExogenized, inxExogenizedAlways, inxExogenizedWhenData] = hereExtractExogenized( );


hereExpandPagesIfNeeded( );


%
% Prepare runtime information
%
this = runtime(this, outputData, "simulate");

%
% Run blazer
% 
[blocks, ~, humanBlocks, dynamicStatus] = blazer(this, opt.Blazer{:});

% /////////////////////////////////////////////////////////////////////////
for blk = 1 : numel(blocks)
    if numel(blocks{blk})==1
        eqn = blocks{blk};
        this__ = this(eqn);
        [isExogenized__, inxExogenizedAlways__, inxExogenizedWhenData__] = hereExtractExogenized__( );
        [plainData, lhs, rhs, res] = createModelData(this__, outputData, controls);
        if dynamicStatus(eqn)
            hereRunRecursive( );
        else
            hereRunOnce(baseRangeColumns);
        end
        updateDataBlock(this__, outputData, plainData);
    else
        for column = baseRangeColumns
            for eqn = reshape(blocks{blk}, 1, [ ])
                this__ = this(eqn);
                [isExogenized__, inxExogenizedAlways__, inxExogenizedWhenData__] = hereExtractExogenized__( );
                [plainData, lhs, rhs, res] = createModelData(this__, outputData, controls);
                hereRunOnce(column);
                updateDataBlock(this__, outputData, plainData);
            end
        end
    end
end
% /////////////////////////////////////////////////////////////////////////


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
pos = textual.locate(lhsNames, outputData.Names);
reorder = [blocks{:}];
pos = pos(reorder);
inxNaNLhs = any(any(~isfinite(outputData.YXEPG(pos, baseRangeColumns, :)), 3), 2);
if any(inxNaNLhs)
    hereReportNaNSimulation( );
end

%
% Create output databank with LHS, RHS and residual names
%
if storeToDatabank
    namesToInclude = [this.LhsName, this.ResidualName];
    outputData = createOutputDatabank(this, inputData, outputData, namesToInclude, [ ], opt);
end

if nargout>=2
    info = struct( );
    info.Blocks = humanBlocks;
    info.DynamicStatus = dynamicStatus;
end

return


    function [isExogenized, inxExogenizedAlways, inxExogenizedWhenData] = hereExtractExogenized( )
        if isempty(opt.Plan)
            isExogenized = false;
            inxExogenizedAlways = logical.empty(0);
            inxExogenizedWhenData = logical.empty(0);
            return
        end
        checkCompatibilityOfPlan(this, range, opt.Plan);
        inxExogenized = opt.Plan.InxOfAnticipatedExogenized | opt.Plan.InxOfUnanticipatedExogenized;
        inxExogenizedWhenData = opt.Plan.InxToKeepEndogenousNaN;
        inxExogenizedAlways = inxExogenized & ~inxExogenizedWhenData;
        isExogenized = nnz(inxExogenized)>0;

        %
        % If some equations are identities, `inxExogenized` is only
        % returned for non-identities; expand the array here and set
        % `inxExogenized` to `false` for all identities/periods.
        %
        inxIdentity = [this.IsIdentity];
        if any(inxIdentity)
            tempWhenData = inxExogenizedWhenData;
            tempAlways = inxExogenizedAlways;
            inxExogenizedWhenData = false(numEquations, numExtendedPeriods, size(tempWhenData, 30));
            inxExogenizedAlways = false(numEquations, numExtendedPeriods, size(tempAlways, 30));
            inxExogenizedWhenData(~inxIdentity, :, :) = tempWhenData;
            inxExogenizedAlways(~inxIdentity, :, :) = tempAlways;
        end
    end%




    function [isExogenized__, inxExogenizedAlways__, inxExogenizedWhenData__] = hereExtractExogenized__( )
        inxExogenizedAlways__ = logical.empty(0);
        inxExogenizedWhenData__ = logical.empty(0);
        if isExogenized
            inxExogenizedAlways__ = inxExogenizedAlways(eqn, :);
            inxExogenizedWhenData__ = inxExogenizedWhenData(eqn, :);
        end
        isExogenized__ = nnz(inxExogenizedAlways__)>0 || nnz(inxExogenizedWhenData__)>0;
    end%




    function hereRunRecursive( )
        posLhs__ = this__.DependentTerm.Position;
        lhsPlainData__ = plainData(posLhs__, :, :);
        inxData__ = ~isnan(lhsPlainData__(1, :, :));
        needsUpdate__ = false;
        for tt = baseRangeColumns
            if needsUpdate__
                date = getIth(extendedRange, tt);
                rhs = updateOwnExplanatoryTerms(this__, rhs, plainData, tt, date, controls);
            end
            columnsToUpdate = double.empty(1, 0);
            needsUpdate__ = false;
            for vv = 1 : numRuns
                if vv<=nv
                    parameters__ = this__.Parameters(:, :, vv);
                end
                %
                % Parameters times RHS terms
                %
                pr__ = parameters__ * rhs(:, tt, vv);

                if isExogenized__ && ( ...
                    inxExogenizedAlways__(1, tt) ...
                    || (inxExogenizedWhenData__(1, tt) && inxData__(1, tt, vv)) ...
                )
                    %
                    % Exogenized point, calculate residuals
                    %
                    res(1, tt, vv) = lhs(1, tt, vv) - pr__;
                else
                    %
                    % Endogenous simulation
                    %
                    if isempty(res)
                        res__ = 0;
                    else
                        res__ = res(1, tt, vv);
                    end
                    lhs(1, tt, vv) = pr__ + res__;
                    columnsToUpdate = [columnsToUpdate, tt];
                    needsUpdate__ = true;
                end
            end
            plainData = updateLhsInPlainData(this__, plainData, lhs, baseRangeColumns);
            plainData = updateResidualsInPlainData(this__, plainData, res, baseRangeColumns);
        end
    end%




    function hereRunOnce(columnsToRun)
        posLhs__ = this__.DependentTerm.Position;
        lhsPlainData__ = plainData(posLhs__, :, :);
        for vv = 1 : numRuns
            if vv<=nv
                parameters__ = this__.Parameters(:, :, vv);
            end
            inxData__ = ~isnan(lhsPlainData__(1, :, vv));
            inxColumnsToRun__ = false(1, numExtendedPeriods);
            inxColumnsToRun__(columnsToRun) = true;
            inxColumnsToExogenize__ = false(1, numExtendedPeriods);
            if isExogenized__
                inxColumnsToExogenize__ = inxColumnsToRun__ & (inxExogenizedAlways__ | (inxExogenizedWhenData__ & inxData__));
                inxColumnsToRun__ = inxColumnsToRun__ & ~inxColumnsToExogenize__;
            end
            if any(inxColumnsToExogenize__)
                %
                % Exogenized points, calculate residuals
                %
                res(1, inxColumnsToExogenize__, vv) = ...
                    lhs(1, inxColumnsToExogenize__, vv) - parameters__*rhs(:, inxColumnsToExogenize__, vv);
            end
            if any(inxColumnsToRun__)
                %
                % Endogenous simulation
                %
                if isempty(res)
                    res__ = 0;
                else
                    res__ = res(1, inxColumnsToRun__, vv);
                end
                lhs(1, inxColumnsToRun__, vv) = parameters__*rhs(:, inxColumnsToRun__, vv) + res__;
            end
        end
        plainData = updateLhsInPlainData(this__, plainData, lhs, columnsToRun);
        plainData = updateResidualsInPlainData(this__, plainData, res, columnsToRun);
    end%




    function hereExpandPagesIfNeeded( )
        if numPages==1 && nv>1
            outputData.YXEPG = repmat(outputData.YXEPG, 1, 1, nv);
            return
        elseif nv==1
            return
        elseif numPages~=nv
            thisError = [ 
                "Explanatory:InconsistentPagesAndVariangs"
                "The number of data pages and the number of Explanatory "
                "parameter variants need to be identical unless one of them is 1." 
            ];
            throw(exception.Base(thisError, 'error'));
        end
    end%




    function hereReportNaNParameters( )
        report = cellstr(lhsNames(inxNaNParameters));
        thisWarning  = [ 
            "Explanatory:MissingObservationInSimulationRange"
            "Some Parameters are NaN or Inf in the Explanatory object"
            "for this LHS variables: %s" 
        ];
        throw(exception.Base(thisWarning, opt.NaNParameters), report{:});
    end%




    function hereReportNaNSimulation( )
        report = cellstr(outputData.Names(pos(inxNaNLhs)));
        thisWarning  = [ 
            "Explanatory:MissingObservationInSimulationRange"
            "Simulation of an Explanatory object produced "
            "NaN or Inf values in this LHS variable: %s" 
        ];
        throw(exception.Base(thisWarning, opt.NaNSimulation), report{:});
    end%
end%




%
% Unit Tests
%{
##### SOURCE BEGIN #####
% saveAs=Explanatory/simulateUnitTest.m

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);

% Set up once
    m1 = Explanatory.fromString("x = 0.8*x{-1} + (1-0.8)*c");
    m2 = Explanatory.fromString("a = b + @*(a{-1} - b) + @");
    m3 = Explanatory.fromString("z = x + a{-1}");
    m4 = Explanatory.fromString("difflog(w) = 0.3*log(5/w{-1})");
    m5 = Explanatory.fromString("c = y");
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


%% Test ARX
    m1 = testCase.TestData.Model1;
    db = testCase.TestData.Databank;
    range = testCase.TestData.Range;
    s = simulate(m1, db, range);
    exd = db.x;
    for t = range
        exd(t) = 0.8*exd(t-1) + (1-0.8)*db.y(t);
    end
    assertEqual(testCase, s.x.Data, exd.Data, 'AbsTol', 1e-12);
    assertEqual(testCase, sort(fieldnames(db)), sort(setdiff(fieldnames(s), 'res_x')));
    assertEqual(testCase, s.w.Data, db.w.Data);


%% Test Transform
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


%% Test ARX Variants
    m2 = testCase.TestData.Model2;
    m2 = alter(m2, 3);
    rho = rand(1, 1, 3);
    m2.Parameters = [rho, zeros(1, 1, 3), ones(1, 1, 3)];
    db = testCase.TestData.Databank;
    db.a = [db.a, db.a+1, db.a+2];
    range = testCase.TestData.Range;
    s = simulate(m2, db, range);
    for i = 1 : 3
        exd = db.a{:, i};
        for t = range
            exd(t) = rho(i)*exd(t-1) + (1-rho(i))*db.b(t);
        end
        assertEqual(testCase, s.a.Data(:, i), exd.Data, 'AbsTol', 1e-12);
    end


%% Test ARX with Residuals
    m1 = testCase.TestData.Model1;
    db = testCase.TestData.Databank;
    range = testCase.TestData.Range;
    db.res_x = Series(range(3:end-3), @randn)/10;
    s = simulate(m1, db, range);
    exd = db.x;
    for t = range
        exd(t) = 0.8*exd(t-1) + (1-0.8)*db.y(t);
        res_x = db.res_x(t);
        if isfinite(res_x)
            exd(t) = exd(t) + res_x;
        end
    end
    assertEqual(testCase, s.x.Data, exd.Data, 'AbsTol', 1e-12);


%% Test ARX Parameters
    m2 = testCase.TestData.Model2;
    rho = rand(1);

    temp = getp(m2, 'Parameters');
    temp(1:2) = [rho, 0];
    m2 = setp(m2, 'Parameters', temp);
    db = testCase.TestData.Databank;
    range = testCase.TestData.Range;
    s = simulate(m2, db, range);
    exp_a = db.a;
    for t = range
        exp_a(t) = rho*exp_a(t-1) + (1-rho)*db.b(t);
    end
    assertEqual(testCase, s.a.Data, exp_a.Data, 'AbsTol', 1e-12);


%% Test ARX System
    m = [ testCase.TestData.Model1
          testCase.TestData.Model2
          testCase.TestData.Model3 ];
    rho = rand(1);
    temp = getp(m(2), 'Parameters');
    temp(1:2) = [rho, 0];
    m(2) = setp(m(2), 'Parameters', temp);
    db = testCase.TestData.Databank;
    range = testCase.TestData.Range;
    s = simulate(m, db, range);
    exp_z = s.x{range} + s.a{-1}{range};
    assertEqual(testCase, s.z.Data, exp_z.Data, 'AbsTol', 1e-12);


%% Test ARX System Variants
    m = [ testCase.TestData.Model1
          testCase.TestData.Model2
          testCase.TestData.Model3 ];
    m = alter(m, 3);
    rho = rand(1, 1, 3);
    m(2).Parameters = [rho, zeros(1, 1, 3), ones(1, 1, 3)];
    db = testCase.TestData.Databank;
    range = testCase.TestData.Range;
    s = simulate(m, db, range);
    exp_z = s.x{range} + s.a{-1}{range};
    assertEqual(testCase, s.z.Data, exp_z.Data, 'AbsTol', 1e-12);


%% Test ARX System with Prepend
    m = [ testCase.TestData.Model1
          testCase.TestData.Model2
          testCase.TestData.Model3 ];
    rho = rand(1);
    m(2).Parameters = [rho, 0, 1];
    range = testCase.TestData.Range;
    db = testCase.TestData.Databank;
    db.x(range(1)+(-10:-2)) = rand(9, 1);
    s = simulate(m, db, range, 'PrependInput=', true);
    exp_z = s.x{range} + s.a{-1}{range};
    assertEqual(testCase, s.z.Data, exp_z.Data, 'AbsTol', 1e-12);
    assertEqual(testCase, double(s.x.Start), range(1)-10);
    assertEqual(testCase, s.x(range(1)+(-10:-2)), db.x(range(1)+(-10:-2)));


%% Test Blazer
    xq = Explanatory.fromString([
        "x = 0.8*y{-1} + 0.8*z{-1}"
        "y = 0.8*x{-1}"
        "a = 0.8*b{-1} + 0.8*a{-2}"
        "b = 0.8*a{-1} + 0.8*b{-2}"
        "z = a"
    ]);
    db = struct( );
    db.a = Series(-1:1000, @rand);
    db.b = Series(-1:1000, @rand);
    db.x = Series(0, rand);
    db.y = Series(0, rand);
    db.z = Series(0, rand);
    simRange = 1:1000;
    [simDb1, info1] = simulate(xq, db, simRange);
    [simDb2, info2] = simulate(xq, db, simRange, 'Blazer=', {'Reorder=', false, 'Dynamic=', true});
    [simDb3, info3] = simulate(xq([1,3,4,5,2]), db, simRange);
    for i = reshape(string(fieldnames(simDb1)), 1, [ ]);
        assertEqual(testCase, simDb1.(i).Data, simDb2.(i).Data, 'AbsTol', 1e-12);
        assertEqual(testCase, simDb1.(i).Data, simDb3.(i).Data, 'AbsTol', 1e-12);
    end


%% Test All ExogenizeWhenData
    xq = Explanatory.fromString([
        "a = b{-1}"
        "b = c{-1}"
        "c = d{-1}"
    ]);
    db = struct( );
    db.d = Series(0:10, 0:10);
    db.c = Series(0:8, 0:10:80);
    db.b = Series(0:6, 0:100:600);
    simDb1 = simulate(xq, db, 1:10);

    p2 = Plan.forExplanatory(xq, 1:10);
    p2 = exogenizeWhenData(p2, 1:10, @all);
    simDb2 = simulate(xq, db, 1:10, 'Plan=', p2);

    assertEqual(testCase, simDb1.c(1:10), db.d{-1}(1:10), 'AbsTol', 1e-14);
    assertEqual(testCase, simDb2.c(1:8), db.c(1:8), 'AbsTol', 1e-14);
    assertEqual(testCase, simDb2.c(9:10), db.d{-1}(9:10), 'AbsTol', 1e-14);

    assertEqual(testCase, simDb1.b(1:10), simDb1.c{-1}(1:10), 'AbsTol', 1e-14);
    assertEqual(testCase, simDb2.b(1:6), db.b(1:6), 'AbsTol', 1e-14);
    assertEqual(testCase, simDb2.b(7:10), simDb2.c{-1}(7:10), 'AbsTol', 1e-14);

    assertEqual(testCase, simDb1.a(1:10), simDb1.b{-1}(1:10), 'AbsTol', 1e-14);
    assertEqual(testCase, simDb2.a(1:10), simDb2.b{-1}(1:10), 'AbsTol', 1e-14);


%% Test Some ExogenizeWhenData
    xq = Explanatory.fromString([
        "a = b{-1};"
        ":exogenous b = c{-1};"
        "c = d{-1};"
    ]);
    db = struct( );
    db.d = Series(0:10, 0:10);
    db.c = Series(0:8, 0:10:80);
    db.b = Series(0:6, 0:100:600);
    simDb1 = simulate(xq, db, 1:10);

    [~, ~, listExogenous] = lookup(xq, ':exogenous');
    p2 = Plan.forExplanatory(xq, 1:10);
    p2 = exogenizeWhenData(p2, 1:10, listExogenous);
    simDb2 = simulate(xq, db, 1:10, 'Plan=', p2);

    assertEqual(testCase, simDb1.c(1:10), db.d{-1}(1:10), 'AbsTol', 1e-14);
    assertEqual(testCase, simDb2.c(1:10), db.d{-1}(1:10), 'AbsTol', 1e-14);

    assertEqual(testCase, simDb1.b(1:10), simDb1.c{-1}(1:10), 'AbsTol', 1e-14);
    assertEqual(testCase, simDb2.b(1:6), db.b(1:6), 'AbsTol', 1e-14);
    assertEqual(testCase, simDb2.b(7:10), simDb2.c{-1}(7:10), 'AbsTol', 1e-14);

    assertEqual(testCase, simDb1.a(1:10), simDb1.b{-1}(1:10), 'AbsTol', 1e-14);
    assertEqual(testCase, simDb2.a(1:10), simDb2.b{-1}(1:10), 'AbsTol', 1e-14);

    simDb3 = simulate(xq, simDb2, 1:10);
    assertEqual(testCase, simDb2.b(1:10), simDb3.b(1:10), 'AbsTol', 1e-14);


%% Test Runtime If
    xq = Explanatory.fromString([
        "a = a{-1} + if(date__==qq(2001,4), 5, 0);"
        "b = b{-1} + if(b{-1}<0, 1, 0);"
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

##### SOURCE END #####
%}
