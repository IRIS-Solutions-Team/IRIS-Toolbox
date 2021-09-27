classdef Comment ...
    < parser.White

    properties (Constant)
        BLOCK_COMMENT_OPEN = '%{'
        BLOCK_COMMENT_CLOSE = '%}'
        LINE_COMMENT = '%'
        LINE_CONTINUATION = '...'
        COMMENT_WHITEOUT = char(0)
        OBSIDIAN_REF = "^\^[^\n]*"
    end


    methods (Static)
        function code = parse(p)
            isCharInp = ischar(p) || isstring(p);
            if isCharInp
                code = char(p);
            else
                code = char(p.Code);
            end
            white = parser.Comment.whiteOutLabels(code);
            white = parser.Comment.whiteOutBlockComment(white);
            white = parser.Comment.whiteOutLineComment(white);
            white = parser.Comment.whiteOutObsidian(white);
            white = parser.Comment.whiteOutLineContinuation(white);
            inx = white==parser.Comment.COMMENT_WHITEOUT;
            code(inx) = '';
            white(inx) = '';
            if ~isCharInp
                p.Code = code;
                p.White = white;
            end
        end%


        function b = whiteOutBlockComment(b)
            sh = zeros(1, numel(b), 'int8');
            posOpen = strfind(b, parser.Comment.BLOCK_COMMENT_OPEN);
            if ~isempty(posOpen)
                sh(posOpen) = 1;
            end
            posClose ...
                = strfind(b, parser.Comment.BLOCK_COMMENT_CLOSE) ...
                + numel(parser.Comment.BLOCK_COMMENT_CLOSE);
            if ~isempty(posClose)
                sh(posClose) = -1;
            end
            b(cumsum(sh)>0) = parser.Comment.COMMENT_WHITEOUT;
        end%


        function wh = whiteOutLineComment(wh)
            s = regexptranslate('escape', parser.Comment.LINE_COMMENT);
            [from, to] = regexp(wh, [s,'[^\n]*'], 'start', 'end');
            wh = parser.Comment.whiteOut(wh, from, to, parser.Comment.COMMENT_WHITEOUT);
        end%


        function b = whiteOutLineContinuation(b)
            s = regexptranslate('escape', parser.Comment.LINE_CONTINUATION);
            [from, to] = regexp(b, [s,'[^\n]*\n?'], 'start', 'end');
            b = parser.Comment.whiteOut(b, from, to, parser.Comment.COMMENT_WHITEOUT);
        end%


        function b = whiteOutObsidian(b)
            [from, to] = regexp(b, parser.Comment.OBSIDIAN_REF, 'start', 'end', 'lineanchors');
            b = parser.Comment.whiteOut(b, from, to, parser.Comment.COMMENT_WHITEOUT);
        end%
    end
end
