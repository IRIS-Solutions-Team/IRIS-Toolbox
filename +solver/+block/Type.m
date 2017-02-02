classdef Type
    enumeration
        UNKNOWN       (-1, '', [ ] )
        SOLVE         ( 0, '!solve_for', [ ] )
        ASSIGN        ( 1, '!assign', [ ] )
        ASSIGN_LOG    ( 2, '!assign_log', @exp )
        ASSIGN_EXP    ( 3, '!assign_exp', @log )
        ASSIGN_UMINUS ( 4, '!assign_uminus', @uminus )
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
        end
        
        
        
        
        function x = int16(this)
            x = this.TypeId;
        end
        
        
        
        
        function c = strcat(this, c)
            switch this
                case solver.block.Type.UNKNOWN
                    c = [ ];
                case solver.block.Type.SOLVE
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
                    throw( exception.Base('General:INTERNAL', 'error') );
            end
        end
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
            throw( exception.Base('General:INTERNAL', 'error') );
        end
    end
end
