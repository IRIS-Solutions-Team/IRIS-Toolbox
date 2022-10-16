% postparse  Parse Explanatorys source file
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function [equationStrings, attributes, controlNames] = postparse(code)

CONTROLS_KEYWORD = "!controls";
EQUATIONS_KEYWORD = "!equations";

%--------------------------------------------------------------------------

%
% Enforce the EQUATIONS_KEYWORD at the beginning of the file
%
code = EQUATIONS_KEYWORD + string(newline()) + string(code);


%
% Split the file into blocks and extract attributes and individual
% equations
%
equationStrings = string.empty(0, 1);
attributes = cell.empty(0, 1);
controlNames = string.empty(1, 0);


reportInvalidBlockAttributes = string.empty(1, 0);
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
        here_parseControlsBlock( );
    elseif keyword==EQUATIONS_KEYWORD
        here_parseEquationsBlock( );
    end
end

if ~isempty(reportInvalidBlockAttributes)
    here_reportInvalidBlockAttributes( );
end

controlNames = unique(controlNames, 'stable');

return

    function here_parseEquationsBlock( )
        %(
        [block, attributes__, status] = local_extractBlockAttributes(block);
        if status~=0
            reportInvalidBlockAttributes = [
                reportInvalidBlockAttributes, ...
                textual.abbreviate(EQUATIONS_KEYWORD + reportBlock, "MaxLength", 30)
            ];
        end

        %
        % Split the block into individual equations by semicolons; replace
        % semicolons within double quotes with alternative (full-width)
        % unicode semicolons first, return them back afterwards
        %
        block = local_protectSemicolons(block);
        equationStrings__ = strip(split(block, ";"));
        equationStrings__ = local_unprotectSemicolons(equationStrings__);

        %
        % Remove empty equations
        %
        equationStrings__(equationStrings__=="" | equationStrings__==";") = [];

        numEquations__ = numel(equationStrings__);
        if numEquations__==0
            return
        end
        equationStrings = [equationStrings; reshape(equationStrings__, [], 1)];
        attributes = [attributes; repmat({attributes__}, numEquations__, 1)];
        %)
    end%


    function here_parseControlsBlock( )
        %(
        controlNames = [controlNames, reshape(regexp(block, "\w+", "match"), 1, [ ])];
        %)
    end%


    function here_reportInvalidBlockAttributes( )
        %(
        thisError = [ 
            "Explanatorys:InvalidBlockAttributes"
            "This %1 keyword is followed by an invalid "
            "list of block attributes: %s "
        ];
        throw( ...
            exception.Base(thisError, 'error') ...
            , EQUATIONS_KEYWORD ...
            , reportInvalidBlockAttributes ...
        ); %#ok<GTARG>
        %)
    end%
end%


%
% Local functions
%


function [block, attributes, status] = local_extractBlockAttributes(block)
    %(
    validateAttribute = @(x) startsWith(x, ":") && isvarname(extractAfter(x, 1));
    status = 0;
    attributes = string.empty(1, 0);
    if ~startsWith(block, "(")
        return
    end
    attributesString = extractBetween(block, "(", ")");
    block = extractAfter(block, ")");
    if isempty(attributesString)
        status = 1;
        return
    end
    % Extract the attributes from the first pair of parentheses
    attributesString = attributesString(1);
    attributes = strip(split(attributesString, compose(["\r\n", "\n", "\r", " ", ",", ";"])));
    attributes(attributes=="") = [ ];
    attributes = reshape(attributes, 1, [ ]);
    if ~all(arrayfun(validateAttribute, attributes))
        status = 1;
        return
    end
    %)
end%


function block = local_protectSemicolons(block)
    %(
    REGULAR_SEMICOLON = ';';
    ALT_SEMICOLON = char(65307);
    block = char(block);

    posQuotes = find(block=='"');
    level = zeros(1, strlength(block));
    level(posQuotes(1:2:end)) = 1;
    level(posQuotes(2:2:end)) = -1;
    level = cumsum(level);
    posSemicolons = find(level>0 & block==REGULAR_SEMICOLON);
    block(posSemicolons) = ALT_SEMICOLON;

    level = textual.bracketLevel(block, "[]");
    block(find(level==1 & block==';')) = ALT_SEMICOLON;

    block = string(block);
    %)
end%


function equationStrings = local_unprotectSemicolons(equationStrings)
    %(
    REGULAR_SEMICOLON = ';';
    ALT_SEMICOLON = char(65307);
    equationStrings = replace(equationStrings, ALT_SEMICOLON, REGULAR_SEMICOLON);
    %)
end%

