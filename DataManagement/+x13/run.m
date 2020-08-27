function [specsFileTitle, message] = run(specsCode, info, opt)

if ispc( )
    executableName = "x13aswin.exe";
elseif ismac( )
    executableName = "x13asmac";
else
    executableName = "x13asunix";
end

x13path = string(fullfile(iris.root( ), "+thirdparty", "x13", executableName));

specsFileTitle = string(tempname("."));
fid = fopen(specsFileTitle + ".spc", "w+t");
fwrite(fid, specsCode);
fclose(fid);

command = x13path + " """ + specsFileTitle + """";
[status, message] = system(command);

if opt.Display
    disp(message);
end

end%

