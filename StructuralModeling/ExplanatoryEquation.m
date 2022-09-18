classdef ExplanatoryEquation ...
    < Explanatory

    methods
        function this = ExplanatoryEquation(varargin)
            this = this@Explanatory(varargin{:});
            thisWarning = [ 
                "Deprecated"
                "ExplanatoryEquation is a deprecated object, and will be discontinued "
                "in a future release of the [IrisToolbox]. Use Explanatory objects instead."
            ];
            throw(exception.Base(thisWarning, 'warning'));
        end%
    end
end
