% simulate  Simulate Explanatory equation or array of equations
%{
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
%>    Explanatory object or array whose equations will be simulated as a
%>    non-simultaneous system.
%
%
% __`inputData`__ [ struct | Dictionary ]
%
%>    Input databank from which ininial conditions and residuals will be
%>    taken; if the option `Plan=` is used with exogenized LHS variables,
%>    the values for these will also be taken from the `inputData`.
%
%
% __`range`__ [ DateWrapper ]
%
%>    Simulation range.
%
%
% Output Arguments
%--------------------------------------------------------------------------
%
% __`outputData`__ [ struct | Dictionary ]
%
%>    Output databank with simulated time series for each LHS variables in
%>    the `expy` system.
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
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

% >=R2019b
%{
function [outputData, info] = simulate(this, inputData, range, opt)

arguments
    this Explanatory
    inputData {local_validateInputData}
    range {validate.properRange}

    opt.AddToDatabank = @auto
    opt.PrependInput (1, 1) logical = false
    opt.AppendInput (1, 1) logical = false

    opt.Blazer (1, :) cell = cell.empty(1, 0)
    opt.NaNParameters (1, 1) string = "warning"
    opt.NaNSimulation (1, 1) string = "warning"
    opt.OutputType (1, 1) string = "struct"
    opt.Plan = []

    opt.SkipWhenData (:, :) logical {mustBeNonempty} = false
    opt.ExogenizeWhenData (:, :) logical {mustBeNonempty} = false

    opt.Progress (1, 1) logical = false
    opt.Journal = false
end
%}
% >=R2019b


% <=R2019a
%(
function [outputData, info] = simulate(this, inputData, range, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();

    addParameter(ip, "AddToDatabank", @auto);
    addParameter(ip, "PrependInput", false);
    addParameter(ip, "AppendInput", false);

    addParameter(ip, "Blazer", cell.empty(1, 0));
    addParameter(ip, "NaNParameters", "warning");
    addParameter(ip, "NaNSimulation", "warning");
    addParameter(ip, "OutputType", "struct");
    addParameter(ip, "Plan", []);

    addParameter(ip, "SkipWhenData", false);
    addParameter(ip, "ExogenizeWhenData", false);

    addParameter(ip, "Progress", false);
    addParameter(ip, "Journal", false);
end
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


storeToDatabank = nargout>=1 && validate.databank(inputData);
journal = Journal(opt.Journal, "@Explanatory/simulate");

%
% Return immediately if this is an empty Explanatory
%
%(
if isempty(this)
    outputData = inputData;
    info = struct( );
    info.Blocks = cell.empty(1, 0);
    info.Period = false;
    return
end
%)


range = double(range);
numEquations = numel(this);
nv = countVariants(this);
if numEquations>1
    if isscalar(opt.SkipWhenData)
        opt.SkipWhenData = repmat(opt.SkipWhenData, 1, numEquations);
    end
    if isscalar(opt.ExogenizeWhenData)
        opt.ExogenizeWhenData = repmat(opt.ExogenizeWhenData, 1, numEquations);
    end
end


%
% Create a DataBlock for all variables across all models; LHS variables are
% only needed when they appear on the RHS (tested within
% `getDataBlock(...)`
%
lhsRequired = false;
context = "for " + this(1).Context + " simulation";
outputData = getDataBlock(this, inputData, range, lhsRequired, context);
extdRange = outputData.ExtendedRange;
numExtdPeriods = outputData.NumExtdPeriods;
numPages = outputData.NumPages;
numRuns = max(nv, numPages);
lhsNames = [this.LhsName];
baseRangeColumns = outputData.BaseRangeColumns;
numBaseRangeColumns = numel(baseRangeColumns);


%
% Create struct with controls
%
%(
if validate.databank(inputData)
    controls = assignControls(this, inputData);
else
    controls = struct( );
end
%)


%
% Extract exogenized points from the Plan
%
[anyExogenized, inxExogenizedAlways, inxExogenizedWhenData] = here_extractExogenized( );


here_expandPagesIfNeeded( );


%
% Prepare runtime information
%
this = runtime(this, outputData, "simulate");


%
% Run blazer and reorder equations
% 
[blocks, ~, humanBlocks, period] = blazer(this, opt.Blazer{:});
numBlocks = numel(blocks);


if opt.Progress
    progress = ProgressBar("@Explanatory/simulate", numBlocks*numBaseRangeColumns*numRuns);
end


%==========================================================================
for blk = 1 : numBlocks
    indent(journal, "Block " + sprintf("%g", blk));
    if numel(blocks{blk})==1
        eqn = blocks{blk};
        this__ = this(eqn);
        lhsName__ = this__.LhsName;
        residualName__ = this__.ResidualName;
        [anyExogenized__, inxExogenizedAlways__, inxExogenizedWhenData__] = here_extractExogenized__( );
        [subBlock, res] = createData4Simulate(this__, outputData, controls);
        if period(eqn)
            %
            % Period by period
            %
            here_runPeriodByPeriod();
        else
            %
            % All periods at once
            %
            here_runOnce(baseRangeColumns);
        end
        updateDataBlock(this__, outputData, subBlock, res);
    else
        for column = baseRangeColumns
            for eqn = reshape(blocks{blk}, 1, [ ])
                this__ = this(eqn);
                lhsName__ = this__.LhsName;
                residualName__ = this__.ResidualName;
                [anyExogenized__, inxExogenizedAlways__, inxExogenizedWhenData__] = here_extractExogenized__( );
                [subBlock, res] = createData4Simulate(this__, outputData, controls);
                here_runOnce(column);
                updateDataBlock(this__, outputData, subBlock, res);
            end
        end
    end
    if journal.IsActive
        deindent(journal);
    end
end
%==========================================================================


%
% Report equations with NaN or Inf parameters
%
inxNaNParameters = arrayfun(@(x) any(any(~isfinite(x.Parameters(1, x.IncParameters, :)))), this);
if any(inxNaNParameters)
    here_reportNaNParameters( );
end


%
% Report LHS variables with NaN or Inf values
%
pos = textual.locate(lhsNames, outputData.Names);
% reorder = [blocks{:}];
% pos = pos(reorder);
inxNaN = any(~isfinite(outputData.YXEPG(pos, baseRangeColumns, :)), 3);
if nnz(inxNaN)>0
    here_reportNaNSimulation();
end


%
% Create output databank with LHS, RHS and residual names
%
if storeToDatabank
    %
    % Create only the LHS variables and their residuals in the output
    % databank; copy RHS-only variables over from the input databank
    %
    namesToInclude = [this.LhsName, this.ResidualName];
    outputData = createOutputDatabank(this, inputData, outputData, namesToInclude, [ ], [ ], opt);
end


if nargout>=2
    info = struct( );
    info.Blocks = humanBlocks;
    info.Period = period;
end

return

    function [anyExogenized, inxExogenizedAlways, inxExogenizedWhenData] = here_extractExogenized( )
        %(
        if isempty(opt.Plan) && ~any(opt.ExogenizeWhenData)
            inxExogenizedAlways = logical.empty(0);
            inxExogenizedWhenData = logical.empty(0);
        elseif ~isempty(opt.Plan)
            checkPlanConsistency(this, range, opt.Plan);
            inxExogenized = opt.Plan.InxOfAnticipatedExogenized | opt.Plan.InxOfUnanticipatedExogenized;
            inxExogenizedWhenData = opt.Plan.InxToKeepEndogenousNaN;
            inxExogenizedAlways = inxExogenized & ~inxExogenizedWhenData;
        else
            inxExogenizedWhenData = false(numEquations, numExtdPeriods);
            inxExogenizedAlways = false(numEquations, numExtdPeriods);
            inxExogenizedWhenData(opt.ExogenizeWhenData, baseRangeColumns, :) = true;
        end

        anyExogenized = (nnz(inxExogenizedAlways) + nnz(inxExogenizedWhenData))>0;
        if ~anyExogenized
            return
        end

        %
        % If some equations are identities, `inxExogenized___` is only
        % returned for non-identities; expand the array here_ and set
        % `inxExogenized___` to `false` for all identities/periods.
        %
        inxIdentity = [this.IsIdentity];
        if any(inxIdentity)
            tempWhenData = inxExogenizedWhenData;
            tempAlways = inxExogenizedAlways;
            inxExogenizedWhenData = false(numEquations, numExtdPeriods, size(tempWhenData, 3));
            inxExogenizedAlways = false(numEquations, numExtdPeriods, size(tempAlways, 3));
            inxExogenizedWhenData(~inxIdentity, :, :) = tempWhenData(~inxIdentity, :, :);
            inxExogenizedAlways(~inxIdentity, :, :) = tempAlways(~inxIdentity, :, :);
        end
        %)
    end%


    function [anyExogenized__, inxExogenizedAlways__, inxExogenizedWhenData__] = here_extractExogenized__( )
        %(
        if anyExogenized
            inxExogenizedAlways__ = inxExogenizedAlways(eqn, :);
            inxExogenizedWhenData__ = inxExogenizedWhenData(eqn, :);
            anyExogenized__ = nnz(inxExogenizedAlways__)>0 || nnz(inxExogenizedWhenData__)>0;
        else
            inxExogenizedAlways__ = logical.empty(0);
            inxExogenizedWhenData__ = logical.empty(0);
            anyExogenized__ = false;
        end
        %)
    end%


    function here_runPeriodByPeriod( )
        posLhs__ = this__.DependentTerm.Position;
        parameters__ = this__.Parameters;
        if size(parameters__, 3)==1 && numRuns>1
            parameters__ = repmat(parameters__, 1, 1, numRuns);
        end
        skipWhenData__ = opt.SkipWhenData(eqn);
        for vv = 1 : numRuns
            if journal.IsActive && numRuns>1
                %(
                indent(journal, "Variant|Page " + sprintf("%g", vv));
                %)
            end
            inxLhsData__ = ~isnan(subBlock(posLhs__, :, vv));
            for tt = baseRangeColumns
                if anyExogenized__ && ...
                    (inxExogenizedAlways__(1, tt) || (inxExogenizedWhenData__(1, tt) && inxLhsData__(1, tt)))
                    %
                    % Exogenized point, calculate residuals
                    %
                    res(:, tt, vv) = this__.EndogenizeResiduals(subBlock, res, parameters__, tt, vv, controls);
                    if journal.IsActive
                        %(
                        write(journal, "Exogenizing " + lhsName__ + "(" + residualName__ + ") " + dater.toDefaultString(extdRange(tt)));
                        %)
                    end
                else
                    %
                    % Endogenous simulation
                    %
                    if skipWhenData__ && inxLhsData__(1, tt)
                        %
                        % Skip
                        %
                        if journal.IsActive
                            %(
                            write(journal, "Skipping " + lhsName__ + " " + dater.toDefaultString(extdRange(tt)));
                            %)
                        end
                    else
                        subBlock(posLhs__, tt, vv) ...
                            = this__.Simulate(subBlock, res, parameters__, tt, vv, controls);
                        if journal.IsActive
                            %(
                            write(journal, "Simulating " + lhsName__ + " " + dater.toDefaultString(extdRange(tt)));
                            %)
                        end
                    end
                end

                if opt.Progress
                    increment(progress);
                end

                if journal.IsActive && numRuns>1
                    %(
                    deindent(journal);
                    %)
                end
            end
        end
    end%


    function here_runOnce(columnsToRun)
        %(
        posLhs__ = this__.DependentTerm.Position;
        parameters__ = this__.Parameters;
        if size(parameters__, 3)==1 && numRuns>1
            parameters__ = repmat(parameters__, 1, 1, numRuns);
        end
        skipWhenData__ = opt.SkipWhenData(eqn);
        for vv = 1 : numRuns
            if journal.IsActive && numRuns>1
                indent(journal, "Variant|Page " + sprintf("%g", vv));
            end
            inxLhsData__ = ~isnan(subBlock(posLhs__, :, vv));
            inxColumnsToRun__ = false(1, numExtdPeriods);
            inxColumnsToRun__(columnsToRun) = true;
            inxColumnsToExogenize__ = false(1, numExtdPeriods);
            if anyExogenized__
                inxColumnsToExogenize__ = ...
                    inxColumnsToRun__ ...
                    & ( inxExogenizedAlways__ | (inxExogenizedWhenData__ & inxLhsData__) );
                inxColumnsToRun__ = inxColumnsToRun__ & ~inxColumnsToExogenize__;
            end

            if any(inxColumnsToExogenize__)
                %
                % Exogenized points, calculate residuals
                %
                tt = find(inxColumnsToExogenize__);
                res(:, tt, vv) ...
                    = this__.EndogenizeResiduals(subBlock, res, parameters__, tt, vv, controls);
                if journal.IsActive
                    [~, s] = dater.reportConsecutive(extdRange(inxColumnsToExogenize__));
                    write(journal, "Exogenizing " + lhsName__ + "(" + residualName__ + ") " + join(s, " "));
                end
            end

            if skipWhenData__
                inxColumnsToRun__ = inxColumnsToRun__ & ~inxLhsData__; 
                if journal.IsActive
                    inxColumnsToSkip__ = inxColumnsToRun__ & inxLhsData__;
                    if any(inxColumnsToSkip__)
                        [~, s] = dater.reportConsecutive(extdRange(inxColumnsToSkip__));
                        write(journal, "Skipping " + lhsName__ + " " + dater.toDefaultString(extdRange(inxColumnsToSkip__)));
                    end
                end
            end

            if any(inxColumnsToRun__)
                %
                % Endogenous simulation
                %
                tt = find(inxColumnsToRun__);
                subBlock(posLhs__, tt, vv) ...
                    = this__.Simulate(subBlock, res, parameters__, tt, vv, controls);
                if journal.IsActive
                    [~, s] = dater.reportConsecutive(extdRange(inxColumnsToRun__));
                    write(journal, "Simulating " + lhsName__ + " " + join(s, " "));
                end
            end
            if opt.Progress
                increment(progress, numBaseRangeColumns);
            end
            if journal.IsActive && numRuns>1
                deindent(journal);
            end
        end
        %)
    end%


    function here_expandPagesIfNeeded()
        %(
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
        %)
    end%


    function here_reportNaNParameters()
        %(
        report = lhsNames(inxNaNParameters);
        thisWarning  = [ 
            "Explanatory:MissingObservationInSimulationRange"
            "Some Parameters are NaN or Inf in the Explanatory object"
            "for this LHS variables: %s" 
        ];
        throw(exception.Base(thisWarning, opt.NaNParameters), report);
        %)
    end%


    function here_reportNaNSimulation()
        %(
        dateStrings = dater.toDefaultString(range);
        report = string.empty(1, 0);
        for row = reshape(find(any(inxNaN, 2)), 1, [])
            report(end+1) = lhsNames(row);
            report(end+1) = textual.rangify(find(inxNaN(row, :)), dateStrings);
        end
        exception.(opt.NaNSimulation)([
            "Explanatory"
            "Simulation of %s produced NaN/Inf: %s"
        ], report);
        %)
    end%
end%

%
% Local Validators
%

function local_validateInputData(input)
    if validate.databank(input)
        return
    end
    if isa(input, 'iris.mixin.DataBlock')
        return
    end
    error("Validation:Failed", "Input value must be a databank");
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
    range = dater.colon(startDate, endDate);
    db = struct( );
    db.x = Series(dater.plus(startDate, -1), 0);
    db.y = Series(range, @rand)*0.5 + 5;
    db.c = db.y;
    db.a = Series(dater.plus(startDate, -1), 0);
    db.b = Series(range, @rand)*0.5 + 5;
    db.w = Series(dater.plus(startDate, -1), 0.5+rand(1, 3)*10);
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
    assertEqual(testCase, s.x.Data, exd.Data, 'absTol', 1e-12);
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
        assertEqual(testCase, s.w.Data(:, i), exp_w.Data, 'absTol', 1e-12);
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
        assertEqual(testCase, s.a.Data(:, i), exd.Data, 'absTol', 1e-12);
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
    assertEqual(testCase, s.x.Data, exd.Data, 'absTol', 1e-12);


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
    assertEqual(testCase, s.a.Data, exp_a.Data, 'absTol', 1e-12);


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
    assertEqual(testCase, s.z.Data, exp_z.Data, 'absTol', 1e-12);


%% Test ARX System Variants
    % m2 = Explanatory.fromString("a = b + @*(a{-1} - b) + @");
    m = [ testCase.TestData.Model1
          testCase.TestData.Model2
          testCase.TestData.Model3 ];
    nv = 3;
    m = alter(m, nv);
    rho = rand(1, 1, nv);
    m(2).Parameters = [rho, zeros(1, 1, nv), ones(1, 1, nv)];
    db = testCase.TestData.Databank;
    range = testCase.TestData.Range;
    db.res_a = Series(range, randn(numel(range), nv));
    s = simulate(m, db, range);
    nb = size(s.b, 2);
    for v = 1 : nv
        exp_res_a = s.a{:,v} - (s.b{:,min(v,nb)} + rho(v)*(s.a{-1}{:,v} - s.b{:,min(v,nb)}) - 0);
        assertEqual(testCase, exp_res_a(range), s.res_a(range, v), 'absTol', 1e-12);
    end
    exp_z = s.x{range} + s.a{-1}{range};
    assertEqual(testCase, s.z.Data, exp_z.Data, 'absTol', 1e-12);


%% Test ARX System with Prepend
    m = [ testCase.TestData.Model1
          testCase.TestData.Model2
          testCase.TestData.Model3 ];
    rho = rand(1);
    m(2).Parameters = [rho, 0, 1];
    range = testCase.TestData.Range;
    db = testCase.TestData.Databank;
    db.x(range(1)+(-10:-2)) = rand(9, 1);
    s = simulate(m, db, range, 'PrependInput', true);
    exp_z = s.x{range} + s.a{-1}{range};
    assertEqual(testCase, s.z.Data, exp_z.Data, 'absTol', 1e-12);
    assertEqual(testCase, double(s.x.Start), range(1)-10);
    assertEqual(testCase, s.x(range(1)+(-10:-2)), db.x(range(1)+(-10:-2)));

%% Test ARX System Variants
    % m2 = Explanatory.fromString("a = b + @*(a{-1} - b) + @");
    m = [ testCase.TestData.Model1
          testCase.TestData.Model2
          testCase.TestData.Model3 ];
    nv = 3;
    m = alter(m, nv);
    rho = rand(1, 1, nv);
    m(2).Parameters = [rho, zeros(1, 1, nv), ones(1, 1, nv)];
    db = testCase.TestData.Databank;
    range = testCase.TestData.Range;
    db.res_a = Series(range, randn(numel(range), nv));
    s = simulate(m, db, range);
    nb = size(s.b, 2);
    for v = 1 : nv
        exp_res_a = s.a{:,v} - (s.b{:,min(v,nb)} + rho(v)*(s.a{-1}{:,v} - s.b{:,min(v,nb)}) - 0);
        assertEqual(testCase, exp_res_a(range), s.res_a(range, v), 'absTol', 1e-12);
    end
    exp_z = s.x{range} + s.a{-1}{range};
    assertEqual(testCase, s.z.Data, exp_z.Data, 'absTol', 1e-12);


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
    [simDb2, info2] = simulate(xq, db, simRange, 'blazer', {'reorder', false, 'period', true});
    [simDb3, info3] = simulate(xq([1,3,4,5,2]), db, simRange);
    for i = reshape(string(fieldnames(simDb1)), 1, [ ]);
        assertEqual(testCase, simDb1.(i).Data, simDb2.(i).Data, 'absTol', 1e-12);
        assertEqual(testCase, simDb1.(i).Data, simDb3.(i).Data, 'absTol', 1e-12);
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
    %
    p2 = Plan.forExplanatory(xq, 1:10);
    p2 = exogenizeWhenData(p2, 1:10, @all);
    simDb2 = simulate(xq, db, 1:10, 'Plan', p2);
    %
    assertEqual(testCase, simDb1.c(1:10), db.d{-1}(1:10), 'absTol', 1e-14);
    assertEqual(testCase, simDb2.c(1:8), db.c(1:8), 'absTol', 1e-14);
    assertEqual(testCase, simDb2.c(9:10), db.d{-1}(9:10), 'absTol', 1e-14);
    %
    assertEqual(testCase, simDb1.b(1:10), simDb1.c{-1}(1:10), 'absTol', 1e-14);
    assertEqual(testCase, simDb2.b(1:6), db.b(1:6), 'absTol', 1e-14);
    assertEqual(testCase, simDb2.b(7:10), simDb2.c{-1}(7:10), 'absTol', 1e-14);
    %
    assertEqual(testCase, simDb1.a(1:10), simDb1.b{-1}(1:10), 'absTol', 1e-14);
    assertEqual(testCase, simDb2.a(1:10), simDb2.b{-1}(1:10), 'absTol', 1e-14);


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
    %
    [~, ~, listExogenous] = lookup(xq, ':exogenous');
    p2 = Plan.forExplanatory(xq, 1:10);
    p2 = exogenizeWhenData(p2, 1:10, listExogenous);
    simDb2 = simulate(xq, db, 1:10, 'Plan', p2);
    %
    assertEqual(testCase, simDb1.c(1:10), db.d{-1}(1:10), 'absTol', 1e-14);
    assertEqual(testCase, simDb2.c(1:10), db.d{-1}(1:10), 'absTol', 1e-14);
    %
    assertEqual(testCase, simDb1.b(1:10), simDb1.c{-1}(1:10), 'absTol', 1e-14);
    assertEqual(testCase, simDb2.b(1:6), db.b(1:6), 'absTol', 1e-14);
    assertEqual(testCase, simDb2.b(7:10), simDb2.c{-1}(7:10), 'absTol', 1e-14);
    %
    assertEqual(testCase, simDb1.a(1:10), simDb1.b{-1}(1:10), 'absTol', 1e-14);
    assertEqual(testCase, simDb2.a(1:10), simDb2.b{-1}(1:10), 'absTol', 1e-14);
    %
    simDb3 = simulate(xq, simDb2, 1:10);
    assertEqual(testCase, simDb2.b(1:10), simDb3.b(1:10), 'absTol', 1e-14);


%% Test Runtime If
    xq = Explanatory.fromString([
        "a = a{-1} + if(a{-1}>20, 1, 5);"
        "b = b{-1} + if(b{-1}<0, 1, 0);"
    ]);
    db = struct( );
    db.a = Series(qq(2000,4), 10);
    db.b = Series(qq(2000,4), -3);
    simDb = simulate(xq, db, qq(2001,1):qq(2004,4));
    exp_a = Series(qq(2000,4):qq(2004,4), [10:5:25, 26:38]');
    assertEqual(testCase, simDb.a(:), exp_a(:), 'absTol', 1e-14);
    exp_b = Series(qq(2000,4):qq(2004,4), 0);
    exp_b(qq(2000,4):qq(2001,2)) = [-3;-2;-1];
    assertEqual(testCase, simDb.b(:), exp_b(:), 'absTol', 1e-14);


%% Test Runtime Ifnan
    xq = Explanatory.fromString([
        "b = ifnan(0.8*c{-1}, z);"
    ], "ControlNames", "z");
    db = struct( );
    db.c = Series(qq(2000,4), rand(20,1));
    db.c(qq(2001,4))=NaN;
    db.c(qq(2003,1:2))=NaN;
    db.z = 100;
    simDb = simulate(xq, db, qq(2001,1):qq(2004,4));
    assertEqual(testCase, simDb.b(qq(2001,4)+1), db.z);
    assertEqual(testCase, simDb.b(qq(2003,1:2)+1), repmat(db.z, 2, 1));
    assertEqual(testCase, simDb.b(qq(2001,1:4)), 0.8*simDb.c(qq(2001,1:4)-1), "absTol", 1e-14);
    assertEqual(testCase, simDb.b(qq(2003,4):qq(2004,4)), 0.8*simDb.c((qq(2003,4):qq(2004,4))-1), "absTol", 1e-14);


%% Test Identity
    xq = Explanatory.fromString([
        "x === a + sin(b)"
        "y = a + sin(b)"
    ]);
    db = struct( );
    db.a = Series(1:10, randn(10, 2));
    db.b = Series(1:10, randn(10, 2));
    simDb1 = simulate(xq, db, 1:10);
    assertFalse(testCase, isfield(simDb1, "res_x"));
    assertTrue(testCase, isfield(simDb1, "res_y"));
    assertEqual(testCase, simDb1.x(1:10), db.a(1:10)+sin(db.b(1:10)), "absTol", 1e-14);
    assertEqual(testCase, simDb1.y(1:10), db.a(1:10)+sin(db.b(1:10)), "absTol", 1e-14);
    assertEqual(testCase, simDb1.res_y(1:10), zeros(10, 2));

    db.res_x = Series(1:10, randn(10, 2)); 
    db.res_y = Series(1:10, randn(10, 2)); 
    simDb2 = simulate(xq, db, 1:10);
    assertTrue(testCase, isfield(simDb2, "res_x")); % [^1] 
    assertTrue(testCase, isfield(simDb2, "res_y"));
    assertEqual(testCase, simDb2.x(1:10), db.a(1:10)+sin(db.b(1:10)), "absTol", 1e-14);
    assertEqual(testCase, simDb2.y(1:10), db.a(1:10)+sin(db.b(1:10))+db.res_y(1:10), "absTol", 1e-14);
    assertEqual(testCase, simDb2.res_y(1:10), db.res_y(1:10));
    % [^1]: res_x is carried over from the input db but unused

##### SOURCE END #####
%}

