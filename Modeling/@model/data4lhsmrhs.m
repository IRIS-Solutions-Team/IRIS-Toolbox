function [YXEPG, rowNames, extendedRange, minShift, maxShift] = data4lhsmrhs(this, inputDatabank, startOfBaseRange, varargin)
% data4lhsmrhs  Prepare data array for running `lhsmrhs`
%
% __Syntax__
%
%     [YXEPG, RowNames, ExtendedRange] = data4lhsmrhs(Model, InpDatabank, StartDate, EndDate)
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
% * `StartDate` [ DateWrapper ] - Start date of the range on which
% [`lhsmrhs`](model/lhsmrhs) will be evaluated.
%
% * `EndDate` [ DateWrapper ] - End date of the range on which
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
% -Copyright (c) 2007-2018 IRIS Solutions Team

TYPE = @int8;

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('model/data4lhsmrhs.m');
    inputParser.addRequired('Model', @(x) isa(x, 'model'));
    inputParser.addRequired('InputDatabank', @isstruct);
    inputParser.addRequired('StartOfBaseRange', @DateWrapper.validateProperRangeInput);
    inputParser.addOptional('EndOfBaseRange', [ ],  @(x) isempty(x) || DateWrapper.validateDateInput(x));
end
inputParser.parse(this, inputDatabank, startOfBaseRange, varargin{:});
endOfBaseRange = inputParser.Results.EndOfBaseRange;

if ischar(startOfBaseRange) || isa(startOfBaseRange, 'string')
    startOfBaseRange = textinp2dat(startOfBaseRange);
end

if ischar(endOfBaseRange) || isa(endOfBaseRange, 'string')
    endOfBaseRange = textinp2dat(endOfBaseRange);
end

if isempty(endOfBaseRange)
    endOfBaseRange = startOfBaseRange(end);
    startOfBaseRange = startOfBaseRange(1);
end

if ~isa(startOfBaseRange, 'DateWrapper')
    startOfBaseRange = DateWrapper.fromDouble(startOfBaseRange);
end

if ~isa(endOfBaseRange, 'DateWrapper')
    endOfBaseRange = DateWrapper.fromDouble(endOfBaseRange);
end

%--------------------------------------------------------------------------

indexOfParameters = this.Quantity.Type==TYPE(4);
rowNames = this.Quantity.Name;
numOfQuantities = numel(rowNames);
rowNamesExceptParameters = rowNames(~indexOfParameters);

[startOfExtendedRange, endOfExtendedRange, minShift, maxShift] = ...
    getExtendedRange(this, startOfBaseRange, endOfBaseRange);
lenOfExtendedRange = rnglen(startOfExtendedRange, endOfExtendedRange);
extendedRange = startOfExtendedRange:endOfExtendedRange;

YXEG = db2array(inputDatabank, rowNamesExceptParameters, extendedRange);
YXEG = permute(YXEG, [2, 1, 3]);

timeTrend = dat2ttrend(extendedRange, this);
numOfDataSets = size(YXEG, 3);

YXEPG = nan(numOfQuantities, lenOfExtendedRange, numOfDataSets);
YXEPG(~indexOfParameters, :, :) = YXEG;

indexOfTimeTrend = strcmp(rowNames, model.RESERVED_NAME_TTREND);
YXEPG(indexOfTimeTrend, :, :) = repmat(timeTrend, 1, 1, numOfDataSets);

end
