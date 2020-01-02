function [equationStrings, attributes] = postparse(code)
% postparse  Parse ExplanatoryEquations source file
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 IRIS Solutions Team

KEYWORD = "!equations";

%--------------------------------------------------------------------------

%
% Enforce the KEYWORD at the beginning of the file
%
code = KEYWORD + newline( ) + string(code);

%
% Split the file into blocks and extract attributes and individual
% equations
%
equationStrings = string.empty(0, 1);
attributes = cell.empty(0, 1);
reportMissingClosing = cell.empty(1, 0);
for block = reshape(split(code, KEYWORD), 1, [ ]);
    block = strtrim(block);
    if block==""
        continue
    end
    [remainingBlock__, attributes__] = hereExtractBlockAttributes(block);
    if ismissing(remainingBlock__)
        report__ = strrep(block, newline( ), ' ');
        reportMissingClosing{end+1} = textual.abbreviate(KEYWORD + report__, 'MaxLength=', 30);
        continue
    end
    equationStrings__ = strtrim(split(remainingBlock__, ";"));
    equationStrings__(equationStrings__=="" | equationStrings__==";") = [ ];
    numEquations__ = numel(equationStrings__);
    equationStrings = [equationStrings; reshape(equationStrings__, [ ], 1)];
    attributes = [attributes; repmat({attributes__}, numEquations__, 1)];
end

if ~isempty(reportMissingClosing)
    hereReportMissingClosing( );
end

return

    function hereReportMissingClosing( )
        thisError = [ "ExplanatoryEquations:MissingClosing"
                      "This keyword %1 with the list of attributes "
                      "has its closing parenthesis missing or misplaced: %s "];
        throw(exception.Base(thisError, 'error'), KEYWORD, reportMissingClosing{:});
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

