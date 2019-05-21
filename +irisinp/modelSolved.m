classdef modelSolved < irisinp.model    
    methods
        function this = modelSolved(varargin)
            % irisinp.modelSolved( ) - solved model with any number of parameterizations.
            % irisinp.modelSolved(1) - solved model with single parameterization.
            this = this@irisinp.model(varargin{:});
            this.ReportName = ['Solved ',this.ReportName];
            validFn = this.ValidFn;
            this.ValidFn = @(x) validFn(x) ...
                && irisinp.modelSolved.myvalidate(x);
        end
    end
        
       
    methods (Static)
        function Flag = myvalidate(x)
            ixSolved = beenSolved(x);
            Flag = ~isempty(ixSolved) && all(ixSolved);
            if isempty(ixSolved)
                utils.warning('inp:modelSolved', ...
                    'Empty model object with no parameterization.');                
            elseif any(~ixSolved)
                utils.warning('inp:modelSolved', ...
                    '#Solution_not_available', ...
                    exception.Base.alt2str(~ixSolved) );
            end
        end
    end
end
