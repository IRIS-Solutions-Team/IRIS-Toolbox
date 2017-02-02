function [C,Flag] = file2char(FName,Type)
% file2char  [Not a public function] Read text file.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

try
    Type; %#ok<VUNUS>
catch
    Type = 'char';
end

%--------------------------------------------------------------------------

Flag = true;
C = '';

if iscellstr(FName) && length(FName)==1
    C = FName{1};
    return
end

% Open, read, and close file.
fid = fopen(FName,'r');
if fid==-1
    if ~utils.exist(FName,'file')
        utils.error('utils:file2char', ...
            'Cannot find file ''%s''.',FName);
    else
        utils.error('utils:file2char', ...
            'Cannot open file ''%s'' for reading.',FName);
    end
end
file = fread(fid,'char').';
if ~ischar(file)
    file = char(file);
end
if fclose(fid)==-1
    utils.warning('utils:file2char', ...
        'Cannot close file ''%s'' after reading.',FName);
end

% Convert any EOLs to \n.
file = textfun.converteols(file);

if isequal(Type,'char')
    C = file;
    return
elseif isequal(Type,'cellstr')
    % Read individual lines into cellstr and remove EOLs.
    eol = strfind(file,sprintf('\n'));
    C = cell(1,length(eol)+1);
    xEol = [0,eol,length(file)+1];
    for i = 1 : length(xEol)-1
        first = xEol(i)+1;
        last = xEol(i+1)-1;
        C{i} = file(first:last);
    end
end

end
