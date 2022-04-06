function [outputFiles, cleanup] = captureOutputFiles(specsFileTitle, opt)

cleanup = string.empty(1, 0);
outputFiles = struct( );
list = dir(specsFileTitle + ".*");
for i = 1 : numel(list)
    [~, ~, ext] = fileparts(list(i).name);
    ext = erase(ext, ".");
    currPath = fullfile(list(i).folder, list(i).name);
    if string(ext)~="spc"
        outputFiles.(ext) = fileread(currPath);
    end
    cleanup(end+1) = currPath;
end

end%

