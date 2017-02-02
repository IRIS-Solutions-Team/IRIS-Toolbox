classdef Comment < parser.White
    properties (Constant)
        BLOCK_COMMENT_OPEN = '%{'
        BLOCK_COMMENT_CLOSE = '%}'
        LINE_COMMENT = '%'
        LINE_CONTINUATION = '...'        
        COMMENT_WHITEOUT = char(0)
    end
    
    
    
    
    methods (Static)
        function c = parse(p)
            import parser.Comment;
            isCharInp = ischar(p);
            if isCharInp
                c = p;
            else
                c = p.Code;
            end
            wh = Comment.whiteOutLabel(c);           
            wh = Comment.whiteOutBlockComment(wh);
            wh = Comment.whiteOutLineComment(wh);
            wh = Comment.whiteOutLineContinuation(wh);
            ix = wh==Comment.COMMENT_WHITEOUT; 
            c(ix) = '';
            wh(ix) = '';
            if ~isCharInp
                p.Code = c;
                p.White = wh;
            end
        end
        
        
        
        
        function b = whiteOutBlockComment(b)
            import parser.Comment;
            sh = zeros(1, length(b), 'int8');
            posOpen = strfind(b, Comment.BLOCK_COMMENT_OPEN);
            if ~isempty(posOpen)
                sh(posOpen) = 1;
            end
            posClose = strfind(b,Comment.BLOCK_COMMENT_CLOSE) ...
                + length(Comment.BLOCK_COMMENT_CLOSE);
            if ~isempty(posClose)
                sh(posClose) = -1;
            end
            b(cumsum(sh)>0) = Comment.COMMENT_WHITEOUT;
        end
        
        
        
        
        
        function wh = whiteOutLineComment(wh)
            import parser.Comment;
            s = regexptranslate('escape', Comment.LINE_COMMENT);
            [from, to] = regexp(wh, [s,'[^\n]*'], 'start', 'end');  
            wh = Comment.whiteOut(wh, from, to, Comment.COMMENT_WHITEOUT);
        end
        
        
        
        
        function b = whiteOutLineContinuation(b)
            import parser.Comment;
            s = regexptranslate('escape', Comment.LINE_CONTINUATION);
            [from, to] = regexp(b, [s,'[^\n]*\n?'], 'start', 'end');  
            b = Comment.whiteOut(b, from, to, Comment.COMMENT_WHITEOUT);
        end
    end
    
end
