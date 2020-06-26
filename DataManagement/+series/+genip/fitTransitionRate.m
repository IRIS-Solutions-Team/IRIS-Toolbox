% fitTransitionConstant  Calculate transition equation autoregression
% coefficient in Rate genip models
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function highRate = fitTransitionRate(aggregation, lowLevel)

%--------------------------------------------------------------------------

numWithin = size(aggregation, 2);
lowTarget = hereRegressTarget( );
highRate = lowTarget .^ (1/numWithin);

return

    function lowTarget = hereRegressTarget( )
        %(
        numLowPeriods = size(lowLevel, 1);
        M = [ones(numLowPeriods, 1), reshape(1:numLowPeriods, [ ], 1)];
        inxObservations = isfinite(lowLevel);
        beta = M(inxObservations, :) \ log(lowLevel(inxObservations));
        lowTarget = exp(beta(end));
        %)
    end%
end%
