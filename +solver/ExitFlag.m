classdef ExitFlag
    enumeration
        % In progress
        IN_PROGRESS      (+0, '')

        % Success
        CONVERGED        (+1, 'Successfully converged. Both step and function tolerance satisfied.')
        ASSIGNED         (+2, 'Successfully assigned.')
        NOTHING_TO_SOLVE (+3, 'Nothing to solve.')
        LINEAR_SYSTEM    (+4, 'Linear system solved.')

        % Failed
        MAX_ITER         (-1, 'Failed. Maximum number of iterations reached.') 
        MAX_FUN_EVALS    (-2, 'Failed. Maximum number of function evaluations reached.') 
        NO_PROGRESS      (-3, 'Failed. Cannot make any further progress.')
        NAN_INF_JACOB    (-4, 'Failed. Jacobian corrupted by NaN or Inf values; cannot move further.') 
        NAN_INF_SOLUTION (-5, 'Failed. Solution corrupted by NaN or Inf values.')
        NAN_INF_PREEVAL  (-6, 'Failed. Equations corrupted by NaN or Inf values.')
        OPTIM_TBX_FAILED (-7, 'Failed. Optimization Toolbox failed to converge.')
    end
    
    
    properties
        Id
        Message
        Iterations
    end
    
    
    methods
        function this = ExitFlag(id, message)
            this.Id = id;
            this.Message = message;
        end%
        
        
        function flag = hasSucceeded(this)
            flag = double(this)>0;
        end%


        function flag = hasFailed(this)
            flag = double(this)<0;
        end%


        function print(this, header)
            if nargin<2 || isempty(header)
                header = '';
            elseif header(end)~=' '
                header = [header, ' '];
            end
            fprintf('\n%s%s\n', header, this.Message);
        end%
        
        
        function x = double(this)
            x = double([this.Id]);
            x = reshape(x, size(this));
        end%
    end


    methods (Static)
        function this = fromOptimTbx(exitFlag)
            if exitFlag>0
                this = solver.ExitFlag.CONVERGED;
            else
                this = solver.ExitFlag.OPTIM_TBX_FAILED;
            end
        end%
    end
end

