function blockCode = readBlockCode(this)
% readBlockCode  Read individual blocks of theparser code
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

numBlocks = length(this.Block);
listBlockKeywords = getBlockKeyword(this);

% Check all words starting with an !
checkKeywords(this, listBlockKeywords);

% Add new line character at the end of the file
if isempty(this.Code) || this.Code(end)~=char(10)
    this.Code(end+1) = char(10);
end

% End of block (eob) is start of another block or end of file
inx = ~cellfun(@isempty, listBlockKeywords);
eob = sprintf('|%s', listBlockKeywords{inx});
eob = ['(?=$', eob, ')'];

% Read blocks
blockCode = repmat({''}, 1, numBlocks);
inxValidEssential = true(1, numBlocks);
for i = 1 : numBlocks
    if isempty(this.Block{i}.Keyword)
        continue
    end
    % Read a whole block
    pattern = [this.Block{i}.Keyword, '[:,;\s]+(.*?)', eob];
    tkn = regexpi(this.Code, pattern, 'tokens');
    tkn = [ tkn{:} ];
    if ~isempty(tkn)
        precheck(this.Block{i}, this, tkn);
        blockCode{i} = [ tkn{:} ];
        % Run block specific regexp replace
        if ~isempty(this.Block{i}.Replace)
            ptn = this.Block{i}.Replace(:,1).';
            rpl = this.Block{i}.Replace(:,2).';
            blockCode{i} = regexprep(blockCode{i}, ptn, rpl);
        end
    end
    if this.Block{i}.IsEssential && this.FN_EMPTY_BLOCK(blockCode{i})
        inxValidEssential(i) = false;
    end
end

if any(~inxValidEssential)
    throw( ...
        exception.ParseTime('TheParser:EssentialBlocksMissing', 'error'), ...
        listBlockKeywords{~inxValidEssential} ...
    );
end

end%


%
% Local Functions
%


function checkKeywords(this, listBlockKeywords)
    % Allow for double exclamation marks immediately followed by \w; these can
    % be steady equations.
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
end%

