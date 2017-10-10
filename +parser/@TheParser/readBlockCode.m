function blockCode = readBlockCode(this)
% readBlockCode  Read individual blocks of theparser code.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

nBlock = length(this.Block);
lsBlockKey = getBlockKeyword(this);

% Check all words starting with an !.
chkKey(this, lsBlockKey);

% Add new line character at the end of the file.
if isempty(this.Code) || this.Code(end)~=char(10)
    this.Code(end+1) = char(10);
end

% End of block (eob) is start of another block or end of file.
inx = ~cellfun(@isempty, lsBlockKey);
eob = sprintf('|%s', lsBlockKey{inx});
eob = ['(?=$', eob, ')'];

% Remove redundant semicolons.
this.Code = regexprep(this.Code, '(\s*;){2,}', ';');

% Read blocks.
blockCode = repmat({''}, 1, nBlock);
ixValidEssential = true(1, nBlock);
for i = 1 : nBlock
    if isempty(this.Block{i}.Keyword)
        continue
    end
    % Read a whole block.
    pattern = [this.Block{i}.Keyword, '[:,;\s]+(.*?)', eob];
    tkn = regexpi(this.Code, pattern, 'tokens');
    tkn = [ tkn{:} ];
    if ~isempty(tkn)
        precheck(this.Block{i}, this, tkn);
        blockCode{i} = [ tkn{:} ];
        % Run block specific regexp replace.
        if ~isempty(this.Block{i}.Replace)
            ptn = this.Block{i}.Replace(:,1).';
            rpl = this.Block{i}.Replace(:,2).';
            blockCode{i} = regexprep(blockCode{i}, ptn, rpl);
        end
    end
    if this.Block{i}.IsEssential && this.FN_EMPTY_BLOCK(blockCode{i})
        ixValidEssential(i) = false;
    end
end

if any(~ixValidEssential)
    throw( ...
        exception.ParseTime('TheParser:EssentialBlocksMissing', 'error'), ...
        lsBlockKey{~ixValidEssential} ...
    );
end
end


function chkKey(this, lsBlockKey)
    % Allow for double exclamation marks immediately followed by \w; these can
    % be steady equations.
    UNKNOWN_KEY = '(?<!\!)!\w+';
    ix = ~cellfun(@isempty, lsBlockKey);
    lsAllowed = [ lsBlockKey(ix), this.OtherKeyword ];
    lsKey = regexp(this.Code, UNKNOWN_KEY, 'match');
    nKey = length(lsKey);
    ixValid = true(1, nKey);
    for iKey = 1 : nKey
        ixValid(iKey) = any(strcmp(lsKey{iKey}, lsAllowed));
    end

    if any(~ixValid)
        throw( exception.ParseTime('TheParser:INVALID_KEYWORD', 'error'), ...
            lsKey{~ixValid} );
    end
end

