function rate = getTransitionRate(model, aggregation, lowData)
% getTransitionConstant  Calculate transition equation autoregression
% coefficient in Rate genip models
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

nw = size(aggregation, 2);
target = hereRegressTarget( );
rate = target .^ (1/nw);

return

    function target = hereRegressTarget( )
        numLowPeriods = size(lowData, 1);
        M = [ones(numLowPeriods, 1), reshape(1:numLowPeriods, [ ], 1)];
        inxObservations = isfinite(lowData);
        beta = M(inxObservations, :) \ log(lowData(inxObservations));
        target = exp(beta(end));
    end%
end%
