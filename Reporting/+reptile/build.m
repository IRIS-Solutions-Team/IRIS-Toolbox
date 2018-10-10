function outputReport = build(fileName, varargin)

rpt = readFile(fileName);
rpt = reptile.parse(rpt);

reptile___ = reptile.Builder( );
assignin('caller', 'reptile___', reptile___);

lines = regexp(rpt, '[^\n]+', 'match');
current = '';
for i = 1 : numel(lines)
    thisLine = lines{i};
    if strncmp(thisLine, '%# ', 3)
        current = thisLine;
        current(1:3) = '';
        continue
    end
    if strncmp(thisLine, '%', 1)
        continue
    end
    try
        evalin('caller', thisLine);
    catch Err
        fprintf('\n%s\n\n', Err.message);
        error( 'reptile:run:SyntaxError', ...
               'Error compilinig report from file "%s" around or after this line: %s ', ...
               fileName, current );
    end
end

outputReport = reptile___.Report;
evalin('caller', 'clear reptile___');
outputReport.Code = rpt;

plot(outputReport, varargin{:});

end%




function rpt = readFile(fileName)
    fid = fopen(fileName);
    if fid<0
        error( 'reptile:run:CannotOpenFile', ...
               'Cannot open this report file: %s ', ...
               fileName );
    end
    try
        rpt = fscanf(fid, '%c');
    catch
        rpt = '';
    end
    fclose(fid);

    if isempty(rpt)
        error( 'reptile:run:CannotOpenFile', ...
               'Cannot read this report file or the file is empty: %s ', ...
               fileName );
    end
end%

