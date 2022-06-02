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


% >=R2019b
%{
function [ ...
    YXEPG, rowNames, extdRange ...
    , minShift, maxShift ...
    , extdTimeTrend, dbInfo ...
] = data4lhsmrhs(this, inputDb, baseRange, opt)

arguments
    this
    inputDb {locallyValidateInputDb} 
    baseRange (1, :) double {validate.mustBeProperRange}

    opt.DbInfo (1, 1) struct = struct()
    opt.IgnoreShocks (1, 1) logical = false
    opt.ResetShocks (1, 1) logical = false
    opt.NumDummyPeriods (1, 1) double {mustBeInteger, mustBeNonnegative} = 0
end
%}
% >=R2019b


% <=R2019a
%(
function [ ...
    YXEPG, rowNames, extdRange ...
    , minShift, maxShift ...
    , extdTimeTrend, dbInfo ...
] = data4lhsmrhs(this, inputDb, baseRange, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addParameter(ip, "DbInfo", struct());
    addParameter(ip, "IgnoreShocks", false);
    addParameter(ip, "ResetShocks", false);
    addParameter(ip, "NumDummyPeriods", 0);
end
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


baseRange = double(baseRange);
baseStart = baseRange(1);
baseEnd = baseRange(end);

inxE = getIndexByType(this.Quantity, 31, 32);
inxP = getIndexByType(this.Quantity, 4);
rowNames = this.Quantity.Name;
numQuants = numel(rowNames);
rowNamesExceptParameters = rowNames(~inxP);

[extdStart, extdEnd, minShift, maxShift] = getExtendedRange(this, [baseStart, baseEnd]);
lenExtdRange = round(extdEnd - extdStart + 1);
extdRange = extdStart:extdEnd;

if isempty(fieldnames(opt.DbInfo))
    allowedNumeric = string.empty(1, 0);
    allowedLog = string.empty(1, 0);
    context = "";
    dbInfo = checkInputDatabank( ...
        this, inputDb, extdRange ...
        , string.empty(1, 0), rowNamesExceptParameters ...
        , allowedNumeric, allowedLog ...
        , context ...
    );
else
    dbInfo = opt.DbInfo;
end

YXEG = requestData(this, dbInfo, inputDb, rowNamesExceptParameters, extdRange);

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


function locallyValidateInputDb(x)
    %(
    if validate.databank(x) || validate.anyString(x, "asynchronous")
        return
    end
    error("Input argument must be a struct or a Dictionary.");
    %)
end%

