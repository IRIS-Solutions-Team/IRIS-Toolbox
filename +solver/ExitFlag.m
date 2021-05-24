classdef ExitFlag
    enumeration
        % In progress
        IN_PROGRESS      (+0, '')

        % Success
        CONVERGED            ( +1, 'Successfully converged. Both step and function tolerance satisfied.')
        ASSIGNED             ( +2, 'Successfully assigned.')
        NOTHING_TO_SOLVE     ( +3, 'Nothing to solve.')
        LINEAR_SYSTEM        ( +4, 'Linear system solved.')

        % Failed
        MAX_ITER             ( -1, 'Failed. Maximum number of iterations reached.') 
        MAX_FUN_EVALS        ( -2, 'Failed. Maximum number of function evaluations reached.') 
        NO_PROGRESS          ( -3, 'Failed. Cannot make any further progress.')
        NAN_INF_JACOB        ( -4, 'Failed. Jacobian ran into NaN or Inf values; cannot move further.') 
        NAN_INF_SOLUTION     ( -5, 'Failed. Solution ran into NaN or Inf values.')
        NAN_INF_PREEVAL      ( -6, 'Failed. Some equations evaluate to NaN or Inf values.')
        OPTIM_TBX_FAILED     ( -7, 'Failed. Optimization Toolbox failed to converge.')
        MAX_ITER_FUN_EVALS   ( -8, 'Failed. Maximum number of iterations or funcion evaluations reached.') 
        OBJ_FUN_FAILED       ( -9, 'Failed. Objective function failed.') 
        LOG_NEGATIVE_ASSIGNED(-10, 'Failed. Negative number assigned to log variable.')
        NAN_INF_OBJECTIVE    (-11, 'Failed. Objective function or its norm evaluates to NaN or Inf.') 
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


        function print(this, header, displayLevel)
            if nargin>=3 && ~displayLevel.Final
                return
            end
            if nargin<2 || isempty(header)
                header = "";
            else
                header = string(header);
            end
            if ~endsWith(header, ' ')
                header = header + " ";
            end
            fprintf('%s%s\n\n', header, this.Message);
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

