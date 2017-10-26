classdef Property < handle
    properties
        FirstOrderSolution = cell(1, 9)
        CovShocks = double.empty(0)
        EigenValues = double.empty(1, 0)
        EigenStability = int8.empty(1, 0)
        NumUnitRoots = NaN
        Specifics = struct( )
    end


    methods
        function x = eval(this)
            x = this.Specifics.Function(this.Specifics);
        end
    end
end

