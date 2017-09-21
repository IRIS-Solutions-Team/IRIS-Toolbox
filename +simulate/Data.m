classdef Data < handle
    properties
        FirstDate % Date of first column
        YXEPG = double.empty(0) % NQ-by-T matrix of [observed; endogenous; expected shocks; parameters; exogenous]
        U = double.empty(0) % NE-by-T matrix of unexpected shocks
        L = double.empty(0) % NYX-by-T matrix of steady levels for [observed; endogenous]
    end


    methods
        function Data(model, inputDatabank, baseRange)
            [this.YXEPG, ~, extendedRange] = data4lhsmrhs(model, inputDatabank, baseRange);
            [this.YXEPG, this.L] = lp4lhsmrhs(model, this.YXEPG,, [ ]);
            this.FirstDate = extendedRange(1);
        end


        function outputDatabank = toDatabank(this, model, extendedRange)
            quantity = getp(model, 'Quantity');
            outputDatabank = databank.fromDoubleArrayNoFrills( ...
                this.YXEPG, quantity.Name, extendedRange(1), quantity.Label ...
            );
        end
    end
end
