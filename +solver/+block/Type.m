classdef Type
    enumeration
        UNKNOWN       (-1, '', [ ] )
        SOLVE         ( 0, 'Solve for ', [ ] )
        ASSIGN        ( 1, 'Assign', [ ] )
        ASSIGN_LOG    ( 2, 'Assign @log', @exp )
        ASSIGN_EXP    ( 3, 'Assign @exp', @log )
        ASSIGN_UMINUS ( 4, 'Assign @uminus', @uminus )
        ITERATE_TIME  ( 5, 'Iterate Period by Period', [ ] )
        EMPTY         ( 6, 'Empty', [ ] )
    end
    
    
    properties
        TypeId
        SaveAsKeyword
        InvTransform
    end
    
    
    methods
        function this = Type(typeId, saveAsKeyword, invTransform)
            PTR = @int16;
            this.TypeId = PTR(typeId);
            this.SaveAsKeyword = saveAsKeyword;
            this.InvTransform = invTransform;
        end%
        
        
        function x = int16(this)
            x = this.TypeId;
        end%


        function flag = isAssignBlock(this)
            flag = this==solver.block.Type.ASSIGN ...
                | this==solver.block.Type.ASSIGN_LOG ...
                | this==solver.block.Type.ASSIGN_EXP ...
                | this==solver.block.Type.ASSIGN_UMINUS ;
        end%


        function flag = isSolveBlock(this)
            flag = this==solver.block.Type.SOLVE;
        end%


        function flag = isIterateBlock(this)
            flag = this==solver.block.Type.ITERATE_TIME;
        end%


        function flag = isEmptyBlock(this)
            flag = this==solver.block.Type.EMPTY;
        end%
        
        
        function c = strcat(this, c)
            switch this
                case solver.block.Type.UNKNOWN
                    c = [ ];
                case solver.block.Type.SOLVE
                    c = [ ];
                case solver.block.Type.ITERATE_TIME
                    c = [ ];
                case solver.block.Type.ASSIGN
                    % c = c;
                case solver.block.Type.ASSIGN_LOG
                    c = strcat('log(', c, ')');
                case solver.block.Type.ASSIGN_EXP
                    c = strcat('exp(', c, ')');
                case solver.block.Type.ASSIGN_UMINUS
                    c = strcat('-', c);
                case solver.block.Type.EMPTY
                    c = [ ];
                otherwise
                    throw(exception.Base('General:Internal', 'error'));
            end
        end%
    end
    
    
    methods (Static)
        function this = getTypeFromId(id)
            PTR = @int16;
            listTypes = enumeration('solver.block.Type');
            for i = 1 : length(listTypes)
                if listTypes(i).TypeId==PTR(id)
                    this = listTypes(i);
                    return
                end
            end
            throw(exception.Base('General:Internal', 'error'));
        end%
    end
end

