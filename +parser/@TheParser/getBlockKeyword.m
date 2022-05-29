function listBlockKeys = getBlockKeyword(this)
% getBlockKeyword  Get list of keywords that start individual blocks
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

numBlocks = numel(this.Block);
listBlockKeys = cell(1, numBlocks);
for i = 1 : numBlocks
    listBlockKeys{i} = this.Block{i}.Keyword;
end
inxEmpty = cellfun(@isempty, listBlockKeys);
listBlockKeys(inxEmpty) = [ ];

end%

