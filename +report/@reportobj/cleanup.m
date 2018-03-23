function cleanup(This)
% cleanup  Clean up temporary files and folders.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Delete all helper files produced when latex codes for children were
% built.

tempFile = This.hInfo.tempFile;
tempDir = This.hInfo.tempDir;
nTempFile = length(tempFile);
isDeleted = false(1,nTempFile);

for i = 1 : nTempFile
    file = tempFile{i};
    if ~isempty(dir(file))
        utils.delete(file);
        isDeleted(i) = isempty(dir(file));
    end
end
tempFile(isDeleted) = [ ];

% Delete temporary dir if empty.
if ~isempty(tempDir)
    status = rmdir(tempDir);
    if status==1
        tempDir = '';
    end
end

This.hInfo.tempFile = tempFile;
This.hInfo.tempDir = tempDir;

end
