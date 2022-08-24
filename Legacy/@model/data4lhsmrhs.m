
% >=R2019b
%{
function [ ...
    YXEPG, rowNames, extdRange ...
    , minShift, maxShift ...
    , trendLine, dbInfo ...
] = data4lhsmrhs(this, inputDb, baseRange, opt)

arguments
    this
    inputDb {local_validateInputDb} 
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
    , trendLine, dbInfo ...
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

numPages = size(YXEG, 3);

if opt.NumDummyPeriods>0
    % Reset the last N periods to NaN
    % here_resetDummyPeriods( );
end

YXEPG = nan(numQuants, lenExtdRange, numPages);
YXEPG(~inxP, :, :) = YXEG;

if opt.ResetShocks
    % Reset NaN shocks to 0
    here_resetShocks( );
end

if opt.IgnoreShocks
    % Zero out all shocks
    here_ignoreShocks( );
end

rowNames = string(this.Quantity.Name);
[YXEPG, trendLine] = insertTrendLine(this, YXEPG, extdRange, rowNames);

return

    function here_resetDummyPeriods( )
        inxToReset = false(1, lenExtdRange);
        inxToReset(end-opt.NumDummyPeriods+1:end) = true;
        YXEG(:, inxToReset, :) = NaN;
    end%


    function here_ignoreShocks( )
        YXEPG(inxE, :, :) = 0;
    end%


    function here_resetShocks( )
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


function local_validateInputDb(x)
    %(
    if validate.databank(x) || validate.anyString(x, "asynchronous")
        return
    end
    error("Input argument must be a struct or a Dictionary.");
    %)
end%

