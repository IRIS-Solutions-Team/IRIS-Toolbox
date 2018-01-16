function char2file(C,FName,Type)
% char2file  [Not a public function] Write character string to text file.
%
% Syntax
% =======
%
%     char2file(C,FName)
%     char2file(C,FName,Type)
%
% Input arguments
% ================
%
% * `C` [ char ] - Character string that will be written to the file.
%
% * `FName` [ char ] - Name of the file.
%
% * `Type` [ char ] - Form and precision of the data written to the file.
%
% Description
% ============
%
% Example
% ========
%
% -The IRIS Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

if nargin < 3
    Type = 'char';
end

%--------------------------------------------------------------------------

fid = fopen(FName,'w+');
if fid == -1
    utils.error('utils:char2file', ...
        'Cannot open file ''%s'' for writing.',FName);
end

if iscellstr(C)
    C = sprintf('%s\n',C{:});
    if ~isempty(C)
        C(end) = '';
    end
end

count = fwrite(fid,C,Type);
if count ~= length(C)
    fclose(fid);
    utils.error('utils:char2file', ...
        'Cannot write character string to file ''%s''.',FName);
end

fclose(fid);

end
