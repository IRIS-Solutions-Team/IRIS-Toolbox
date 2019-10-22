classdef Keyword < int8
    enumeration
        NONE        (  0 )
        END         (  1 - 1i )
        
        IF          (  2 + 1i )
        ELSEIF      (  3 )
        ELSE        (  4 )

        EXPORT      (  5 + 1i )
        FUNCTION    ( 16 + 1i )

        FOR         (  6 + 1i )
        DO          (  7 )
        RETURN      (  17 )

        SWITCH      (  8 + 1i )
        CASE        (  9 )
        OTHERWISE   ( 10 )

        IMPORT      ( 11 )
        INCLUDE     ( 12 )
        INPUT       ( 13 )
        CLONE       ( 16 )
        
        STOP        ( 15 )
    end
    
    
    
    
    methods
        function this = Keyword(varargin)
            this = this@int8(varargin{:});
        end%

        function c = toChar(this)
            c = ['!', lower(char(this))];
        end%

        function n = len(this)
            n = 1 + length(char(this));
        end%
    end        
end

