function [outputDb, info] = simulate(this, inputDb, range, varargin)
%{
% simulate  Simulate Explanatory model
%
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
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------


% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

persistent pp
if isempty(pp)
    pp = extend.InputParser('Explanatory/simulate');

    addRequired(pp, 'explanatory', @(x) isa(x, 'Explanatory'));
    addRequired(pp, 'inputDb', @validate.databank);
    addRequired(pp, 'simulationRange', @DateWrapper.validateProperRangeInput);

    addParameter(pp, 'AddToDatabank', @auto, @(x) isequal(x, @auto) || isequal(x, [ ]) || validate.databank(x));
    addParameter(pp, {'AppendPostsample', 'AppendInput'}, false, @validate.logicalScalar);
    addParameter(pp, {'AppendPresample', 'PrependInput'}, false, @validate.logicalScalar);
    addParameter(pp, 'OutputType', 'struct', @validate.databankType);
    addParameter(pp, 'NaNParameters', 'Warning', @(x) validate.anyString(x, 'Error', 'Warning', 'Silent'));
    addParameter(pp, 'NaNSimulation', 'Warning', @(x) validate.anyString(x, 'Error', 'Warning', 'Silent'));
    addParameter(pp, 'Plan', [ ], @(x) isempty(x) || isa(x, 'Plan'));
    addParameter(pp, 'RaggedEdge', @auto, @(x) isequal(x, @auto) || validate.logicalScalar(x));
    addParameter(pp, 'Blazer', cell.empty(1, 0), @iscell);
end
parse(pp, this, inputDb, range, varargin{:});
opt = pp.Options;

storeToDatabank = nargout>=1;

%--------------------------------------------------------------------------

if isempty(this)
    outputDb = inputDb;
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
dataBlock = getDataBlock(this, inputDb, range, lhsRequired, context);
numExtendedPeriods = dataBlock.NumOfExtendedPeriods;
numPages = dataBlock.NumOfPages;
numRuns = max(nv, numPages);
lhsNames = [this.LhsName];
baseRangeColumns = dataBlock.BaseRangeColumns;
extendedRange = DateWrapper(dataBlock.ExtendedRange);


%
% Create struct with controls
%
controls = assignControls(this, inputDb);


%
% Extract exogenized points from the Plan
%
[isExogenized, inxExogenizedAlways, inxExogenizedWhenData] = hereExtractExogenized( );


hereExpandPagesIfNeeded( );


%
% Prepare runtime information
%
this = runtime(this, dataBlock, "simulate");

%
% Run blazer
% 
[blocks, ~, humanBlocks, dynamicStatus] = blazer(this, opt.Blazer{:});


%//////////////////////////////////////////////////////////////////////////
for blk = 1 : numel(blocks)
    if numel(blocks{blk})==1
        eqn = blocks{blk};
        this__ = this(eqn);
        [isExogenized__, inxExogenizedAlways__, inxExogenizedWhenData__] = hereExtractExogenized__( );
        [plainData, lhs, rhs, res] = createModelData(this__, dataBlock, controls);
        if dynamicStatus(eqn)
            hereRunRecursive( );
        else
            hereRunOnce(baseRangeColumns);
        end
        updateDataBlock(this__, dataBlock, plainData);
    else
        for column = baseRangeColumns
            for eqn = reshape(blocks{blk}, 1, [ ])
                this__ = this(eqn);
                [isExogenized__, inxExogenizedAlways__, inxExogenizedWhenData__] = hereExtractExogenized__( );
                [plainData, lhs, rhs, res] = createModelData(this__, dataBlock, controls);
                hereRunOnce(column);
                updateDataBlock(this__, dataBlock, plainData);
            end
        end
    end
end
%//////////////////////////////////////////////////////////////////////////


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
    namesToInclude = [this.LhsName, this.ResidualName];
    outputDb = createOutputDatabank(this, inputDb, dataBlock, namesToInclude, [ ], opt);
end

info = struct( );
info.Blocks = humanBlocks;
info.DynamicStatus = dynamicStatus;

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
        posLhs__ = this__.Dependent.Position;
        lhsPlainData__ = plainData(posLhs__, :, :);
        inxData__ = ~isnan(lhsPlainData__(1, :, :));
        needsUpdate__ = false;
        for tt = baseRangeColumns
            if needsUpdate__
                date = getIth(extendedRange, tt);
                rhs = updateOwnExplanatory(this__.Explanatory, rhs, plainData, tt, date, controls);
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
            plainData = updatePlainData(this__.Dependent, plainData, lhs, res, baseRangeColumns);
        end
    end%




    function hereRunOnce(columnsToRun)
        posLhs__ = this__.Dependent.Position;
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
        plainData = updatePlainData(this__.Dependent, plainData, lhs, res, columnsToRun);
    end%




    function hereExpandPagesIfNeeded( )
        if numPages==1 && nv>1
            dataBlock.YXEPG = repmat(dataBlock.YXEPG, 1, 1, nv);
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
        report = cellstr(dataBlock.Names(pos(inxNaNLhs)));
        thisWarning  = [ 
            "Explanatory:MissingObservationInSimulationRange"
            "Simulation of an Explanatory object produced "
            "NaN or Inf values in this LHS variable: %s" 
        ];
        throw(exception.Base(thisWarning, opt.NaNSimulation), report{:});
    end%
end%

