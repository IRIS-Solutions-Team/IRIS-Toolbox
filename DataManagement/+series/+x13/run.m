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

command = x13path + " """ + specFileName + """";
[status, result] = system(command);

if opt.Display
    disp(result);
end

numOutputTables = numel(outputTables);
varargout = cell.empty(1, 0);
for n = outputTables
    tableFileName = specFileName + "." + n;
    temp = textscan(string(fileread(tableFileName)), "%f %f", 'HeaderLines', 2);
    varargout{end+1} = temp{2};
    delete(tableFileName);
end

info = struct( );
for n = ["log", "out", "err"]
    outputFileName = specFileName + "." + n;
    info.(n) = string(fileread(outputFileName));
    delete(outputFileName);
end

end%

