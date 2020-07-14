% postparse  Parse Explanatorys source file
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function [equationStrings, attributes, controlNames] = postparse(code)

CONTROLS_KEYWORD = "!controls";
EQUATIONS_KEYWORD = "!equations";

%--------------------------------------------------------------------------

%
% Enforce the EQUATIONS_KEYWORD at the beginning of the file
%
code = EQUATIONS_KEYWORD + string(newline( )) + string(code);


%
% Split the file into blocks and extract attributes and individual
% equations
%
equationStrings = string.empty(0, 1);
attributes = cell.empty(0, 1);
controlNames = string.empty(1, 0);


reportMissingClosing = cell.empty(1, 0);
[blocks, keywords] = split(code, [EQUATIONS_KEYWORD, CONTROLS_KEYWORD]);
blocks(1) = [ ];
numBlocks = numel(blocks);
for i = 1 : numBlocks
    reportBlock = blocks(i);
    block = strip(blocks(i));
    if block==""
        continue
    end
    keyword = keywords(i);

    if keyword==CONTROLS_KEYWORD
        hereParseControlsBlock( );
    elseif keyword==EQUATIONS_KEYWORD
        hereParseEquationsBlock( );
    end
end

controlNames = unique(controlNames, 'stable');

return

    function hereParseEquationsBlock( )
        %(
        [block, attributes__] = locallyExtractBlockAttributes(block);
        equationStrings__ = strip(split(block, ";"));
        equationStrings__(equationStrings__=="" | equationStrings__==";") = [ ];
        numEquations__ = numel(equationStrings__);
        if numEquations__==0
            return
        end
        equationStrings = [equationStrings; reshape(equationStrings__, [ ], 1)];
        attributes = [attributes; repmat({attributes__}, numEquations__, 1)];
        %)
    end%


    function hereParseControlsBlock( )
        %(
        controlNames = [controlNames, reshape(regexp(block, "\w+", "match"), 1, [ ])];
        %)
    end%


    function hereReportMissingClosing( )
        %(
        thisError = [ "Explanatorys:MissingClosing"
                      "This keyword %1 with the list of attributes "
                      "has its closing parenthesis missing or misplaced: %s "];
        throw(exception.Base(thisError, 'error'), EQUATIONS_KEYWORD, reportMissingClosing{:});
        %)
    end%
end%


%
% Local Functions
%


function [block, attributes] = locallyExtractBlockAttributes(block)
    %(
    attributes = string.empty(1, 0);
    if ~startsWith(block, "(")
        return
    end
    attributesString = extractBetween(block, "(", ")");
    if isempty(attributesString)
        reportMissingClosing{end+1} = textual.abbreviate(EQUATIONS_KEYWORD + reportBlock, 'MaxLength=', 30);
        return
    end
    attributes = regexp(attributesString, ":\w+", "match");
    block = extractAfter(block, ")");
    %)
end%

