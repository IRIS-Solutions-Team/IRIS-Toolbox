classdef ExitFlag
    enumeration
        ITERATING     (0,  '')
        CONVERGED     (1,  'Successfully converged. Both step tolerance and function tolerance satisfied.')
        MAX_ITER      (-1, 'Failed. Maximum number of iterations reached.') 
        MAX_FUN_EVALS (-2, 'Failed. Maximum number of function evaluations reached.') 
        NO_PROGRESS   (-3, 'Failed. Cannot make any further progress.')
        NAN_INF_JACOB (-4, 'NaN or Inf in Jacobian. Cannot move further.') 
    end
    
    
    
    
    properties
        Id
        Message
    end
    
    
    
    
    methods
        function this = ExitFlag(id, message)
            this.Id = id;
            this.Message = message;
        end
        
        
        
        
        function print(this)
            fprintf('\n%s\n', this.Message);
        end
        
        
        
        
        function x = double(this)
            x = this.Id;
        end
    end
end
