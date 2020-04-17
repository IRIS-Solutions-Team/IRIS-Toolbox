function [equationStrings, attributes, controlNames] = postparse(code)
% postparse  Parse Explanatorys source file
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

CONTROLS_KEYWORD = "!controls";
EQUATIONS_KEYWORD = "!equations";

%--------------------------------------------------------------------------

%
% Enforce the EQUATIONS_KEYWORD at the beginning of the file
%
code = EQUATIONS_KEYWORD + newline( ) + string(code);

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
    block = strtrim(blocks(i));
    if block==""
        continue
    end
    keyword = keywords(i);

    if keyword==CONTROLS_KEYWORD
        hereParseControlsBlock( )
    elseif keyword==EQUATIONS_KEYWORD
        hereParseEquationsBlock( )
    end
end

controlNames = unique(controlNames, 'stable');

if ~isempty(reportMissingClosing)
    hereReportMissingClosing( );
end

return

    function hereParseEquationsBlock( )
        [remainingBlock__, attributes__] = hereExtractBlockAttributes(block);
        if ismissing(remainingBlock__)
            report__ = strrep(block, newline( ), ' ');
            reportMissingClosing{end+1} = textual.abbreviate(EQUATIONS_KEYWORD + report__, 'MaxLength=', 30);
            return
        end
        equationStrings__ = strtrim(split(remainingBlock__, ";"));
        equationStrings__(equationStrings__=="" | equationStrings__==";") = [ ];
        numEquations__ = numel(equationStrings__);
        equationStrings = [equationStrings; reshape(equationStrings__, [ ], 1)];
        attributes = [attributes; repmat({attributes__}, numEquations__, 1)];
    end%


    function hereParseControlsBlock( )
        controlNames = [controlNames, reshape(regexp(block, "\w+", "match"), 1, [ ])];
    end%


    function hereReportMissingClosing( )
        thisError = [ "Explanatorys:MissingClosing"
                      "This keyword %1 with the list of attributes "
                      "has its closing parenthesis missing or misplaced: %s "];
        throw(exception.Base(thisError, 'error'), EQUATIONS_KEYWORD, reportMissingClosing{:});
    end%
end%


%
% Local Functions
%


function [remainingBlock, attributes, missing] = hereExtractBlockAttributes(block)
    if ~startsWith(block, "(")
        remainingBlock = block;
        attributes = string.empty(1, 0);
        return
    end
    attributes = regexp(extractBefore(block, ")"), ":\w+", "match");
    remainingBlock = extractAfter(block, ")");
end%

