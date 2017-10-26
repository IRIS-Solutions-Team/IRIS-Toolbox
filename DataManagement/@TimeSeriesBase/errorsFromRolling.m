function [output, tabPred, tabErr] = rmseFromRolling(obs, pred, horizon, rollingDates)

obsRange = obs.Range;
obsData = obs.Data;

startDate = min(obs.Start, min(rollingDates));
endDate = max(obs.End, max(rollingDates)) + max(horizon);
numPeriods = rnglen(startDate, endDate);

obsData = getDataNoFrills(obs, startDate:endDate);
predData = getDataNoFrills(pred, startDate:endDate);
rawErrData = predData - obsData;

numRollingDates = numel(rollingDates);
numHorizon = numel(horizon);
tabPredData = nan(numPeriods, numHorizon);
tabErrData = nan(numPeriods, numHorizon);
for i = 1 : numRollingDates
    ithDate = rollingDates(i);
    row = rnglen(startDate, ithDate);
    tabPredData(row, :) = predData(row+horizon, i);
    tabErrData(row, :) = rawErrData(row+horizon, i);
end

output = struct( );

% Count of observations available to calculate statistics on each horizon.
output.Count = sum(~isnan(tabErrData), 1);

% Mean (average) error.
output.Me = nanmean(tabErrData, 1);

% Mean absolute error (deviation).
ae = abs(tabErrData);
output.Mad = nanmean(ae, 1);

% Root mean squre error.
se = tabErrData.^2;
mse = nanmean(se, 1);
output.Rmse = sqrt(mse);

tabPred = Series(startDate, tabPredData);
tabErr = Series(startDate, tabErrData);

end

