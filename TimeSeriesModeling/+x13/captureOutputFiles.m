function outputFiles = captureOutputFiles(specsFileTitle, opt)

outputFiles = struct( );
list = dir(specsFileTitle + ".*");
for i = 1 : numel(list)
    [~, ~, ext] = fileparts(list(i).name);
    ext = erase(ext, ".");
    path = fullfile(list(i).folder, list(i).name);
    if string(ext)~="spc"
        outputFiles.(ext) = fileread(path);
    end
    if opt.Cleanup
        delete(path);
    end
end

end%

