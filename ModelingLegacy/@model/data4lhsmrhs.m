function [ YXEPG, rowNames, extendedRange, ...
           minShift, maxShift, extendedTimeTrend ] = data4lhsmrhs( this, inputDatabank, ...
                                                                   baseRange, varargin )
% data4lhsmrhs  Prepare data array for running `lhsmrhs`
%
% __Syntax__
%
%     [YXEPG, RowNames, ExtendedRange] = data4lhsmrhs(Model, InpDatabank, Range)
%
%
% __Input Arguments__
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
% __Output Arguments__
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
% __Description__
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
% __Example__
%
%     YXEPG = data4lhsmrhs(m, d, range);
%     d = lhsmrhs(m, YXEPG);
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

TYPE = @int8;

persistent parser
if isempty(parser)
    parser = extend.InputParser('model/data4lhsmrhs.m');
    parser.addRequired('Model', @(x) isa(x, 'model'));
    parser.addRequired('InputDatabank', @isstruct);
    parser.addRequired('BaseRange', @DateWrapper.validateProperRangeInput);
    parser.addParameter('IgnoreShocks', false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('ResetShocks', false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('NumOfDummyPeriods', 0, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>=0);
end
parser.parse(this, inputDatabank, baseRange, varargin{:});
opt = parser.Options;

if ischar(baseRange) || isa(baseRange, 'string')
    baseRange = textinp2dat(baseRange);
end

baseRange = double(baseRange);
startOfBaseRange = baseRange(1);
endOfBaseRange = baseRange(end);

%--------------------------------------------------------------------------

inxOfE = getIndexByType(this.Quantity, TYPE(31), TYPE(32));
inxOfP = getIndexByType(this.Quantity, TYPE(4));
rowNames = this.Quantity.Name;
numOfQuants = numel(rowNames);
rowNamesExceptParameters = rowNames(~inxOfP);

[startOfExtendedRange, endOfExtendedRange, minShift, maxShift] = ...
    getExtendedRange(this, [startOfBaseRange, endOfBaseRange]);
lenOfExtendedRange = round(endOfExtendedRange - startOfExtendedRange + 1);
extendedRange = startOfExtendedRange:endOfExtendedRange;

check = checkInputDatabank(this, inputDatabank, extendedRange, [ ], rowNamesExceptParameters);
YXEG = requestData(this, check, inputDatabank, extendedRange, rowNamesExceptParameters);

% YXEG = db2array(inputDatabank, rowNamesExceptParameters, extendedRange);
% YXEG = permute(YXEG, [2, 1, 3]);

extendedTimeTrend = dat2ttrend(extendedRange, this);
numOfDataSets = size(YXEG, 3);

if opt.NumOfDummyPeriods>0
    % Reset the last N periods to NaN
    hereResetDummyPeriods( );
end

YXEPG = nan(numOfQuants, lenOfExtendedRange, numOfDataSets);
YXEPG(~inxOfP, :, :) = YXEG;

if opt.ResetShocks
    % Reset NaN shocks to 0
    hereResetShocks( );
end

if opt.IgnoreShocks
    % Zero out all shocks
    hereIgnoreShocks( );
end

inxOfTimeTrend = strcmp(rowNames, model.RESERVED_NAME_TTREND);
YXEPG(inxOfTimeTrend, :, :) = repmat(extendedTimeTrend, 1, 1, numOfDataSets);

return


    function hereResetDummyPeriods( )
        inxToReset = false(1, lenOfExtendedRange);
        inxToReset(end-opt.NumOfDummyPeriods+1:end) = true;
        YXEG(:, inxToReset, :) = NaN;
    end%


    function hereIgnoreShocks( )
        YXEPG(inxOfE, :, :) = 0;
    end%


    function hereResetShocks( )
        inxOfNaN = isnan(YXEPG);
        if nnz(inxOfNaN)==0
            return
        end
        inxToReset = true(size(YXEPG));
        inxToReset(~inxOfE, :, :) = false;
        inxToReset = inxToReset & inxOfNaN;
        if nnz(inxToReset)==0
            return
        end
        YXEPG(inxToReset) = 0;
    end%
end%

