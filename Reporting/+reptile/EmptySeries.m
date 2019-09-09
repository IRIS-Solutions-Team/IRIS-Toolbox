classdef EmptySeries < reptile.Base
    properties (Constant)
        ExpressionToEval = ''
        Value = NaN
        LegendEntries = cell.empty(1, 0)
        CanBeParent = {'reptile.Axes'}
    end


    methods
        function this = EmptySeries(parent)
           this = this@reptile.Base(parent, ''); 
        end%


        function eval(this, varargin)
        end%
    end
end
