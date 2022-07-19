% fitTransitionConstant  Calculate transition equation autoregression
% coefficient in Rate genip models
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function highRate = fitTransitionRate(aggregation, lowLevel)

    % Number of high-freq periods within one low-freq period
    numWithin = size(aggregation, 2);

    numLowPeriods = size(lowLevel, 1);
    M = [ones(numLowPeriods, 1), reshape(1:numLowPeriods, [ ], 1)];
    inxObservations = isfinite(lowLevel);
    beta = M(inxObservations, :) \ log(lowLevel(inxObservations));
    lowTarget = exp(beta(end));

    highRate = lowTarget .^ (1/numWithin);

end%
