classdef Type
    enumeration
        UNKNOWN       (-1, '', [ ] )
        SOLVE         ( 0, 'Solver for ', [ ] )
        ASSIGN        ( 1, 'Assign', [ ] )
        ASSIGN_LOG    ( 2, 'Assign @log', @exp )
        ASSIGN_EXP    ( 3, 'Assign @exp', @log )
        ASSIGN_UMINUS ( 4, 'Assign @uminus', @uminus )
        ITERATE_TIME  ( 5, 'Iterate Period by Period', [ ] )
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
                otherwise
                    throw(exception.Base('General:Internal', 'error'));
            end
        end%
    end
    
    
    
    
    methods (Static)
        function this = getTypeFromId(id)
            PTR = @int16;
            ls = enumeration('solver.block.Type');
            for i = 1 : length(ls)
                if ls(i).TypeId==PTR(id)
                    this = ls(i);
                    return
                end
            end
            throw(exception.Base('General:Internal', 'error'));
        end%
    end
end
