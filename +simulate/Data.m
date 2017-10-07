classdef Data < handle
    properties
        FirstDate % Date of first column
        YXEPG = double.empty(0) % NQ-by-T matrix of [observed; endogenous; expected shocks; parameters; exogenous]
        U = double.empty(0) % NE-by-T matrix of unexpected shocks
        L = double.empty(0) % NYX-by-T matrix of steady levels for [observed; endogenous]
        Expected
        Unexpected
    end


    methods
        function outputDatabank = toDatabank(this, model)
            names = get(model, 'Quantity.Name');
            labels = get(model, 'Quantity.Label');
            outputDatabank = databank.fromDoubleArrayNoFrills( ...
                this.YXEPG, names, this.FirstDate, labels ...
            );
        end
    end


    methods (Static)
        function this = fromDatabank(model, inputDatabank, baseRange, anticipate)
            TYPE = @int8;
            this = simulate.Data( );
            [this.YXEPG, ~, extendedRange] = data4lhsmrhs(model, inputDatabank, baseRange);
            [this.YXEPG, this.L] = lp4lhsmrhs(model, this.YXEPG, Inf, [ ]);
            this.FirstDate = extendedRange(1);
            type = get(model, 'Quantity.Type');
            for i = find(type==TYPE(31) | type==TYPE(32))
                e = this.YXEPG(i, :, :);
                e(isnan(e)) = 0;
                this.YXEPG(i, :, :) = e;
            end
        end
    end
end
