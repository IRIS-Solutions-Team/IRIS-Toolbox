
function [specsFileTitle, message] = run(specsCode, info)

    if ispc()
        executableName = "x13aswin.exe";
    elseif ismac()
        executableName = "x13asmac";
    else
        executableName = "x13asunix";
    end

    x13path = fullfile(iris.get("X13Path"), executableName);

    specsFileTitle = string(tempname('.'));
    fid = fopen(specsFileTitle + ".spc", "w+t");
    fwrite(fid, specsCode);
    fclose(fid);

    command = x13path + " """ + specsFileTitle + """";
    [status, message] = system(command);

end%

