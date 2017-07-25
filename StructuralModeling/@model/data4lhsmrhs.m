function [YXEPG, lsName, xRange] = data4lhsmrhs(this, inp, range)
% data4lhsmrhs  Prepare data array for running `lhsmrhs`.
%
% Syntax
% =======
%
%     [YXEPG, list, xRange] = data4lhsmrhs(m, inp, range)
%
%
% Input arguments
% ================
%
% * `m` [ model ] - Model object whose equations will be later evaluated by
% calling [`lhsmrhs`](model/lhsmrhs).
%
% * `inp` [ struct ] - Input database with observations on measurement
% variables, transition variables, and shocks on which
% [`lhsmrhs`](model/lhsmrhs) will be evaluated.
%
% * `range` [ numeric | char ] - Date range on which
% [`lhsmrhs`](model/lhsmrhs) will be evaluated.
%
%
% Output arguments
% =================
% 
% * `YXEPG` [ numeric ] - Numeric array with the observations on
% measurement variables, transition variables, shocks and exogenous
% variables (including time trend) organized row-wise.
%
% * `list` [ cellstr ] - List of measurement variables, transition
% variables and shocks in order of their appearance in the rows of `YXEPG`.
%
% * `xRange` [ numeric ] - Extended range including pre-sample and
% post-sample observations needed to evaluate lags and leads of transition
% variables.
%
%
% Description
% ============
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
% Example
% ========
%
%     YXEPG = data4lhsmrhs(m, d, range);
%     d = lhsmrhs(m, YXEPG);
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

pp = inputParser( );
pp.addRequired('m', @(x) isa(x, 'model'));
pp.addRequired('inp', @isstruct);
pp.addRequired('range', @(x) isdatinp(x));
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

lsName = qty.Name(ixyxeg);

xRange = getXRange(this, range);
nXPer = length(xRange);

YXEG = db2array(inp, lsName, xRange);
YXEG = permute(YXEG, [2, 1, 3]);

ttrend = dat2ttrend(xRange, this);
nData = size(YXEG, 3);

YXEPG = nan(nQty, nXPer, nData);
YXEPG(ixyxeg, :, :) = YXEG;

ixTtrend = strcmp(qty.Name, model.RESERVED_NAME_TTREND);
YXEPG(ixTtrend, :, :) = repmat(ttrend, 1, 1, nData);

end
