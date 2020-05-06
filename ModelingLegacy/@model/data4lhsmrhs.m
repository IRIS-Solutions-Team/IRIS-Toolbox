function [ ...
    YXEPG, rowNames, extendedRange, ...
    minShift, maxShift, extendedTimeTrend ...
] = data4lhsmrhs( ...
    this, inputDb, baseRange, varargin ...
)
% data4lhsmrhs  Prepare data array for running `lhsmrhs`
%{
% ## Syntax ##
%
%     [YXEPG, RowNames, ExtendedRange] = data4lhsmrhs(Model, InpDatabank, Range)
%
%
% ## Input Arguments ##
%
% * `Model` [ model ] - Model object whose equations will be later
% evaluated by calling [`lhsmrhs`](model/lhsmrhs).
%
% * `InpDatabank` [ struct ] - Input database with observations on
% measurement variables, transition variables, and shocks on which
% [`lhsmrhs`](model/lhsmrhs) will be evaluated.
%
% * `Range` [ DateWrapper ] - Continuous range on which
% [`lhsmrhs`](model/lhsmrhs) will be evaluated.
%
%
% ## Output Arguments ##
% 
% * `YXEPG` [ numeric ] - Numeric array with the observations on
% measurement variables, transition variables, shocks and exogenous
% variables (including time trend) organized row-wise.
%
% * `RowNames` [ cellstr ] - List of measurement variables, transition
% variables, shocks, parameters and exogenous variables in order of their
% appearance in the rows of `YXEPG`.
%
% * `ExtendedRange` [ DateWrapper ] - Extended range including pre-sample
% and post-sample observations needed to evaluate lags and leads of
% transition variables.
%
%
% ## Description ##
%
% The output array, `YXEPG`, is N-by-T-by-K where N is the total number of
% all quantities in the `Model` (measurement variables, transition
% variables, shocks, parameters, and exogenous variables including a time
% trend), T is the number of periods including the pre-sample and
% post-sample periods needed to evaluate lags and leads, and K is the
% number of alternative data sets (i.e. the number of columns in each input
% time series) in the `InputDatabank`.
%
%
% ## Example ##
%
%     YXEPG = data4lhsmrhs(m, d, range);
%     d = lhsmrhs(m, YXEPG);
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

TYPE = @int8;

persistent pp
if isempty(pp)
    pp = extend.InputParser('model/data4lhsmrhs.m');
    %
    % Required input arguments
    %
    addRequired(pp, 'model', @(x) isa(x, 'model'));
    addRequired(pp, 'inputDb', @(x) validate.databank(x) || isequal(x, "asynchronous"));
    addRequired(pp, 'baseRange', @DateWrapper.validateProperRangeInput);
    %
    % Options
    %
    addParameter(pp, 'IgnoreShocks', false, @(x) isequal(x, true) || isequal(x, false));
    addParameter(pp, 'ResetShocks', false, @(x) isequal(x, true) || isequal(x, false));
    addParameter(pp, 'NumOfDummyPeriods', 0, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>=0);
end
pp.parse(this, inputDb, baseRange, varargin{:});
opt = pp.Options;

if ischar(baseRange) || isa(baseRange, 'string')
    baseRange = textinp2dat(baseRange);
end

baseRange = double(baseRange);
startBaseRange = baseRange(1);
endBaseRange = baseRange(end);

%--------------------------------------------------------------------------

inxE = getIndexByType(this.Quantity, TYPE(31), TYPE(32));
inxP = getIndexByType(this.Quantity, TYPE(4));
rowNames = this.Quantity.Name;
numQuants = numel(rowNames);
rowNamesExceptParameters = rowNames(~inxP);

[startExtendedRange, endExtendedRange, minShift, maxShift] = ...
    getExtendedRange(this, [startBaseRange, endBaseRange]);
lenExtendedRange = round(endExtendedRange - startExtendedRange + 1);
extendedRange = startExtendedRange:endExtendedRange;

check = checkInputDatabank(this, inputDb, extendedRange, [ ], rowNamesExceptParameters);
YXEG = requestData(this, check, inputDb, extendedRange, rowNamesExceptParameters);

extendedTimeTrend = dat2ttrend(extendedRange, this);
numDataSets = size(YXEG, 3);

if opt.NumOfDummyPeriods>0
    % Reset the last N periods to NaN
    % hereResetDummyPeriods( );
end

YXEPG = nan(numQuants, lenExtendedRange, numDataSets);
YXEPG(~inxP, :, :) = YXEG;

if opt.ResetShocks
    % Reset NaN shocks to 0
    hereResetShocks( );
end

if opt.IgnoreShocks
    % Zero out all shocks
    hereIgnoreShocks( );
end

inxTimeTrend = strcmp(rowNames, model.component.Quantity.RESERVED_NAME_TTREND);
YXEPG(inxTimeTrend, :, :) = repmat(extendedTimeTrend, 1, 1, numDataSets);

return


    function hereResetDummyPeriods( )
        inxToReset = false(1, lenExtendedRange);
        inxToReset(end-opt.NumOfDummyPeriods+1:end) = true;
        YXEG(:, inxToReset, :) = NaN;
    end%


    function hereIgnoreShocks( )
        YXEPG(inxE, :, :) = 0;
    end%


    function hereResetShocks( )
        inxNaN = isnan(YXEPG);
        if nnz(inxNaN)==0
            return
        end
        inxToReset = true(size(YXEPG));
        inxToReset(~inxE, :, :) = false;
        inxToReset = inxToReset & inxNaN;
        if nnz(inxToReset)==0
            return
        end
        YXEPG(inxToReset) = 0;
    end%
end%

