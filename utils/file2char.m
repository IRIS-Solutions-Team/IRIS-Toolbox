function [c, flag] = file2char(fileName, Type)
% file2char  Read text file
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

UTF = char([239, 187, 191]);

try
    Type; %#ok<VUNUS>
catch
    Type = 'char';
end

%--------------------------------------------------------------------------

flag = true;
c = '';

if iscellstr(fileName) && length(fileName)==1
    c = fileName{1};
    return
end

% Open, read, and close file
fid = fopen(fileName, 'r');
if fid==-1
    if ~exist(fileName, 'file')
        utils.error('utils:file2char', ...
            'Cannot find this file: %s ', fileName);
    else
        utils.error('utils:file2char', ...
            'Cannot open this file for reading: %s ', fileName);
    end
end
file = fread(fid, 'char').';
if ~ischar(file)
    file = char(file);
end
if fclose(fid)==-1
    utils.warning('utils:file2char', ...
        'Cannot close this file after reading: %s ', fileName);
end

% Remove UTF-8 CSV mark
if strncmp(file, UTF, length(UTF))
    file = file(length(UTF)+1:end);
end

% Convert any EOLs to \n
file = textfun.converteols(file);

if isequal(Type, 'char')
    c = file;
    return
elseif isequal(Type, 'cellstr')
    % Read individual lines into cellstr and remove EOLs
    eol = strfind(file, sprintf('\n'));
    c = cell(1, length(eol)+1);
    xEol = [0, eol, length(file)+1];
    for i = 1 : length(xEol)-1
        first = xEol(i)+1;
        last = xEol(i+1)-1;
        c{i} = file(first:last);
    end
end

end%

