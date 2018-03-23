function lsBlockKey = getBlockKeyword(this)
% getBlockKeyword  Get list of keywords that start individual blocks.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

nBlock = length(this.Block);
lsBlockKey = cell(1, nBlock);
for i = 1 : nBlock
    lsBlockKey{i} = this.Block{i}.Keyword;
end
ixEmpty = cellfun(@isempty, lsBlockKey);
lsBlockKey(ixEmpty) = [ ];

end
