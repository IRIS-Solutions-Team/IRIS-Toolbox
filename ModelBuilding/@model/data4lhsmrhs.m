function [YXEPG, rowNames, extendedRange] = data4lhsmrhs(this, inputDatabank, baseRange)
% data4lhsmrhs  Prepare data array for running `lhsmrhs`.
%
% __Syntax__
%
%     [YXEPG, RowNames, ExtRange] = data4lhsmrhs(Model, InpDatabank, Range)
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
% * `Range` [ DateWrapper ] - Date range on which
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
% * `ExtRange` [ DateWrapper ] - Extended range including pre-sample
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

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

TYPE = @int8;

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('model/data4lhsmrhs.m');
    INPUT_PARSER.addRequired('Model', @(x) isa(x, 'model'));
    INPUT_PARSER.addRequired('InputDatabank', @isstruct);
    INPUT_PARSER.addRequired('Range', @DateWrapper.validateDateInput);
end
INPUT_PARSER.parse(this, inputDatabank, baseRange);

if ischar(baseRange)
    baseRange = textinp2dat(baseRange);
end

%--------------------------------------------------------------------------

ixp = this.Quantity.Type==TYPE(4);
rowNames = this.Quantity.Name;
numOfQuantities = numel(rowNames);
rowNamesExceptParameters = rowNames(~ixp);

extendedRange = getExtendedRange(this, baseRange);
lenOfExtendedRange = length(extendedRange);

YXEG = db2array(inputDatabank, rowNamesExceptParameters, extendedRange);
YXEG = permute(YXEG, [2, 1, 3]);

timeTrend = dat2ttrend(extendedRange, this);
numOfDataSets = size(YXEG, 3);

YXEPG = nan(numOfQuantities, lenOfExtendedRange, numOfDataSets);
YXEPG(~ixp, :, :) = YXEG;

indexOfTimeTrend = strcmp(rowNames, model.RESERVED_NAME_TTREND);
YXEPG(indexOfTimeTrend, :, :) = repmat(timeTrend, 1, 1, numOfDataSets);

end
