classdef Dynamic < solver.blazer.Blazer
    properties
    end
    
    
    
    
    methods
        function this = Dynamic(varargin)
            this = this@solver.blazer.Blazer(varargin{:});
        end

        
        
        
        function prepareBlock(this, blz, opt)
            prepareBlock@solver.block.Block(this, blz, opt);
            
            % Prepare function handles and auxiliary matrices for gradients.
            this.RetGradient = opt.Gradient && this.Type==solver.block.Type.SOLVE;
            if this.RetGradient
                [this.Gradient, this.XX2L, this.D] = ...
                    createFnGradient(this, blz, opt);
            end
        end
    end
end
