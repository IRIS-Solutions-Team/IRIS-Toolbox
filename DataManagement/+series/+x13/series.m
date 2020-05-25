function code = series(data, startDate, opt)

NAN_STANDIND = -99999;

[startYear, startPeriod, freq] = dat2ypf(startDate);

data = locallyAdjustDataForNaNs(data, NAN_STANDIND);

code = [
    "series{"
    "    start=" + startYear + "." + startPeriod
    "    period=" + freq
    "    decimals=" + opt.Series_Decimals
    "    precision=" + opt.Series_Precision
    "    data=("
             compose("        %g", data)
    "    )"
    "}"
    " "
    " "
];

end%


%
% Local Functions
%


function data = locallyAdjustDataForNaNs(data, standin)
    %(
    data(data==standin) = standin - 0.01;
    data(~isfinite(data)) = standin;
    %)
end%

