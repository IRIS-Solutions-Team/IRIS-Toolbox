function const = getTransitionConstant(model, aggregation, lowData)
% getTransitionConstant  Calculate transition equation constant in Level,
% Diff or DiffDiff genip models
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

nw = size(aggregation, 2);

if strcmpi(model, 'Level')
    order = 0;
elseif strcmpi(model, 'Diff')
    order = 1;
elseif strcmpi(model, 'DiffDiff')
    order = 2;
end

target = hereRegressTarget( );
const = hereCalculateConstant( );

return

    function target = hereRegressTarget( )
        numLowPeriods = size(lowData, 1);
        M = ones(numLowPeriods, 1);
        for i = 1 : order
            M = [M, cumsum(M(:, end), 1)]; 
        end
        inxObservations = isfinite(lowData);
        beta = M(inxObservations, :) \ lowData(inxObservations);
        target = beta(end);
    end%


    function const = hereCalculateConstant( )
        x = ones(nw*(order+1), 1);
        for i = 1 : order
            x = cumsum(x);
        end
        y = aggregation*reshape(x, nw, [ ]);
        if order>0
            y = diff(y, order, 2);
        end
        const = target / y;
    end%
end%
