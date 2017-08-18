function [YXEPG, listOfNames, extendedRange] = data4lhsmrhs(this, inp, range)
% data4lhsmrhs  Prepare data array for running `lhsmrhs`.
%
% __Syntax__
%
%     [YXEPG, List, ExtendedRange] = data4lhsmrhs(M, Inp, Range)
%
%
% __Input Arguments__
%
% * `M` [ model ] - Model object whose equations will be later evaluated by
% calling [`lhsmrhs`](model/lhsmrhs).
%
% * `Inp` [ struct ] - Input database with observations on measurement
% variables, transition variables, and shocks on which
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
% * `List` [ cellstr ] - List of measurement variables, transition
% variables and shocks in order of their appearance in the rows of `YXEPG`.
%
% * `ExtendedRange` [ DateWrapper ] - Extended range including pre-sample
% and post-sample observations needed to evaluate lags and leads of
% transition variables.
%
%
% __Description__
%
% The output array, `YXEPG`, is `nVar` by `nXPer` by `nData`, where `nVar`
% is the total number of measurement variables, transition variables,
% shocks and exogenous variables (including time trend), `nXPer` is the
% number of periods including the pre-sample and post-sample periods needed
% to evaluate lags and leads, and `nData` is the number of alternative data
% sets (i.e. the number of columns in each input time series) in the input
% database, `Inp`.
%
%
% __Example__
%
%     YXEPG = data4lhsmrhs(m, d, range);
%     d = lhsmrhs(m, YXEPG);
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

pp = inputParser( );
pp.addRequired('M', @(x) isa(x, 'model'));
pp.addRequired('Inp', @isstruct);
pp.addRequired('Range', @DateWrapper.validateDateInput);
pp.parse(this, inp, range);

if ischar(range)
    range = textinp2dat(range);
end

%--------------------------------------------------------------------------

qty = this.Quantity;
nQty = length(this.Quantity);
ixy = qty.Type==TYPE(1);
ixx = qty.Type==TYPE(2);
ixe = qty.Type==TYPE(31) | qty.Type==TYPE(32);
ixg = qty.Type==TYPE(5);
ixyxeg = ixy | ixx | ixe | ixg;

listOfNames = qty.Name(ixyxeg);

extendedRange = getXRange(this, range);
nXPer = length(extendedRange);

YXEG = db2array(inp, listOfNames, extendedRange);
YXEG = permute(YXEG, [2, 1, 3]);

ttrend = dat2ttrend(extendedRange, this);
nData = size(YXEG, 3);

YXEPG = nan(nQty, nXPer, nData);
YXEPG(ixyxeg, :, :) = YXEG;

ixTtrend = strcmp(qty.Name, model.RESERVED_NAME_TTREND);
YXEPG(ixTtrend, :, :) = repmat(ttrend, 1, 1, nData);

end
