function [info, varargout] = run(specCode, outputTables, opt)

if ispc( )
    executableName = 'x13aswin.exe';
elseif ismac( )
    executableName = 'x13asmac';
else
    executableName = 'x13asunix';
end
x13path = string(fullfile(iris.root( ), "+thirdparty", "x13", executableName));

specFileName = string(tempname( ));
fid = fopen(specFileName + ".spc", "w+");
fwrite(fid, specCode);
fclose(fid);

info = struct( );
command = x13path + " """ + specFileName + """";
[status, info.Message] = system(command);

if opt.Display
    disp(info.Message);
end

numOutputTables = numel(outputTables);
varargout = cell.empty(1, 0);
for n = outputTables
    tableFileName = specFileName + "." + n;
    try
        temp = textscan(string(fileread(tableFileName)), "%f %f", 'HeaderLines', 2);
        varargout{end+1} = temp{2};
    catch
        varargout{end+1} = [ ];
    end
    if exist(tableFileName, 'file')
        delete(tableFileName);
    end
end

for n = ["spc", "log", "out", "err"]
    outputFileName = specFileName + "." + n;
    try
        info.(n) = string(fileread(outputFileName));
    catch
        info.(n) = "";
    end
    if exist(outputFileName, 'file')
        delete(outputFileName);
    end
end

end%

