% cleanup  Clean up temporary files and folders

function cleanup(this)

    tempFile = this.hInfo.tempFile;
    tempDir = this.hInfo.tempDir;
    numOfTempFiles = length(tempFile);
    beenDeleted = false(1, numOfTempFiles);

    for i = 1 : numOfTempFiles
        file = tempFile{i};
        if ~isempty(dir(file))
            delete(file);
            beenDeleted(i) = isempty(dir(file));
        end
    end
    tempFile(beenDeleted) = [ ];

    if ~isempty(tempDir)
        status = rmdir(tempDir);
        if status==1
            tempDir = '';
        end
    end

    this.hInfo.tempFile = tempFile;
    this.hInfo.tempDir = tempDir;

end%
