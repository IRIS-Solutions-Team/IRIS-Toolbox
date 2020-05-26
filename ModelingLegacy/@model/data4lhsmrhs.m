% data4lhsmrhs  Prepare model data array
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

function [ ...
    YXEPG, rowNames, extdRange ...
    , minShift, maxShift ...
    , extdTimeTrend, dbInfo ...
] = data4lhsmrhs(this, inputDb, baseRange, varargin)

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

TYPE = @int8;

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('@Model/data4lhsmrhs.m');

    addRequired(pp, 'model', @(x) isa(x, 'model'));
    addRequired(pp, 'inputDb', @(x) validate.databank(x) || isequal(x, "asynchronous"));
    addRequired(pp, 'baseRange', @DateWrapper.validateProperRangeInput);

    addParameter(pp, 'IgnoreShocks', false, @(x) isequal(x, true) || isequal(x, false));
    addParameter(pp, 'ResetShocks', false, @(x) isequal(x, true) || isequal(x, false));
    addParameter(pp, 'NumDummyPeriods', 0, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>=0);
end
%)
opt = parse(pp, this, inputDb, baseRange, varargin{:});

if ischar(baseRange) || isa(baseRange, 'string')
    baseRange = textinp2dat(baseRange);
end

baseRange = double(baseRange);
baseStart = baseRange(1);
baseEnd = baseRange(end);

%--------------------------------------------------------------------------

inxE = getIndexByType(this.Quantity, TYPE(31), TYPE(32));
inxP = getIndexByType(this.Quantity, TYPE(4));
rowNames = this.Quantity.Name;
numQuants = numel(rowNames);
rowNamesExceptParameters = rowNames(~inxP);

[extdStart, extdEnd, minShift, maxShift] = getExtendedRange(this, [baseStart, baseEnd]);
lenExtdRange = round(extdEnd - extdStart + 1);
extdRange = extdStart:extdEnd;

dbInfo = checkInputDatabank(this, inputDb, extdRange, [ ], rowNamesExceptParameters);
YXEG = requestData(this, dbInfo, inputDb, extdRange, rowNamesExceptParameters);

extdTimeTrend = dat2ttrend(extdRange, this);
numPages = size(YXEG, 3);

if opt.NumDummyPeriods>0
    % Reset the last N periods to NaN
    % hereResetDummyPeriods( );
end

YXEPG = nan(numQuants, lenExtdRange, numPages);
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
YXEPG(inxTimeTrend, :, :) = repmat(extdTimeTrend, 1, 1, numPages);

return


    function hereResetDummyPeriods( )
        inxToReset = false(1, lenExtdRange);
        inxToReset(end-opt.NumDummyPeriods+1:end) = true;
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

