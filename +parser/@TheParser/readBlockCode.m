% readBlockCode  Read individual blocks of theparser code
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function [blockCode, blockAttributes] = readBlockCode(this)

numBlocks = numel(this.Block);
listBlockKeywords = getBlockKeyword(this);

% Check all words starting with an !
locallyCheckKeywords(this, listBlockKeywords);

% Add new line character at the end of the file
if isempty(this.Code) || this.Code(end)~=char(10)
    this.Code(end+1) = char(10);
end

% End of block (eob) is start of another block or end of file
inx = ~cellfun(@isempty, listBlockKeywords);
eob = sprintf('|%s', listBlockKeywords{inx});
eob = ['(?=$', eob, ')'];

% Read blocks
blockCode = cell(1, numBlocks);
blockAttributes = cell(1, numBlocks);
inxValidEssential = true(1, numBlocks);
for i = 1 : numBlocks
    if isempty(this.Block{i}.Keyword)
        continue
    end
    % Read a whole block
    pattern = [this.Block{i}.Keyword, '([\(:,;\s].*?)', eob];
    tkn = regexpi(string(this.Code), string(pattern), "tokens");
    tkn = string([tkn{:}]);
    [tkn, blockAttributes{i}] = hereReadAttributes(tkn);
    check = [];
    if ~isempty(tkn)
        precheck(this.Block{i}, this, tkn);
        blockCode{i} = strip(tkn);
        % Run block specific regexp replace
        if ~isempty(this.Block{i}.Replace)
            ptn = this.Block{i}.Replace(:,1).';
            rpl = this.Block{i}.Replace(:,2).';
            blockCode{i} = regexprep(blockCode{i}, ptn, rpl);
        end
        check = join(blockCode{i}, "");
    end
    if this.Block{i}.IsEssential && this.FN_EMPTY_BLOCK(check)
        inxValidEssential(i) = false;
    end
end

if any(~inxValidEssential)
    throw( ...
        exception.ParseTime('TheParser:EssentialBlocksMissing', 'error'), ...
        listBlockKeywords{~inxValidEssential} ...
    );
end

    function [block, attributes] = hereReadAttributes(block)
        getFirst = @(x) x(1);
        inx = startsWith(block, "(");
        attributes = repmat({string.empty(1, 0)}, size(block));
        for ii = find(reshape(inx, 1, []))
            temp = getFirst(extractBetween(block(ii), "(", ")"));
            attributes{ii} = regexp(temp, ":\w+", "match");
            if isempty(attributes{ii})
                attributes{ii} = string.empty(1, 0);
            end
            block(ii) = extractAfter(block(ii), ")");
        end
    end%

end%

%
% Local Functions
%

function locallyCheckKeywords(this, listBlockKeywords)
    % Allow for double exclamation marks immediately followed by \w; these can
    % be steady equations.
    %(
    UNKNOWN_KEY = '(?<!\!)!\w[\w\-]+';
    inx = ~cellfun(@isempty, listBlockKeywords);
    listAllowed = [ listBlockKeywords(inx), this.OtherKeyword ];
    listKeywords = regexp(this.Code, UNKNOWN_KEY, 'match');
    numKeywords = length(listKeywords);
    inxValid = true(1, numKeywords);
    for iKey = 1 : numKeywords
        inxValid(iKey) = any(strcmp(listKeywords{iKey}, listAllowed));
    end

    if any(~inxValid)
        throw( ...
            exception.ParseTime('TheParser:INVALID_KEYWORD', 'error'), ...
            listKeywords{~inxValid} ...
        );
    end
    %)
end%

