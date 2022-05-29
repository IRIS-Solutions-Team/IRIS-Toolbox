function [file, flag] = file2char(fileName, varargin)
% file2char  Read file to character vector or cellstr array
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted
%
%     c = file2char(fileName, ~precision, ...)
%
%
% __Input Arguments__
%
% * `fileName` [ char | string ] - Name of the source file.
%
% * `~precision='char'` [ char | string ] - Matlab precision specificatio
% for the `fread(~)` function.%
%
% 
% __Options__
%
% * `MachineFormat='Native'` [ char | string ] - Order for writing bytes
% and bits in the destination file.
%
% * `Encoding=@auto` [ `@auto` | char | string ] - Encoding scheme for from
% the source file; `@auto` means the operating system default scheme.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

splitByLines = false;
if nargin==1
    precision = 'char';
else
    precision = varargin{1};
    varargin(1) = [ ];
    if strcmpi(precision, 'cellstr')
        precision = 'char';
        splitByLines = true;
    end
end

persistent parser
if isempty(parser)
    parser = extend.InputParser('file2char');
    parser.addRequired('FileName', @validate.string);
    parser.addRequired('Precision', @validate.string);
    parser.addParameter('MachineFormat', 'Native', @validate.string);
    parser.addParameter('Encoding', @auto, @(x) isequal(x, @auto) || validate.string(x));
end
parse(parser, fileName, precision, varargin{:});
opt = parser.Options;

%--------------------------------------------------------------------------

flag = true;
c = '';

if iscellstr(fileName) && length(fileName)==1
    c = fileName{1};
    return
end

fid = hereOpenFile( );

file = hereReadFromFile( );

hereRemoveUTFBOM( );

% Convert any EOLs to \n
file = textual.convertEndOfLines(file);

if splitByLines
    hereConvertToCell( );
end

return


    function fid = hereOpenFile( )
        if isequal(opt.Encoding, @auto)
            fid = fopen(fileName, 'r', opt.MachineFormat);
        else
            fid = fopen(fileName, 'r', opt.MachineFormat, opt.Encoding);
        end
        if fid==-1
            THIS_ERROR = { 'CannotOpenFileForWriting'
                           'Cannot open this file for reading: %s ' };
            throw( exception.Base(THIS_ERROR, 'error'), ...
                   fileName );
        end
    end%


    function file = hereReadFromFile( )
        size = Inf;
        skip = 0;
        file = fread(fid, size, precision, skip, opt.MachineFormat);
        status = fclose(fid);
        if status==-1
            THIS_WARNING = { 'CannotCloseFile'
                             'Cannot close this file after reading: %s ' };
            throw( exception.Base(THIS_WARNING, 'warning'), ...
                   fileName ); 
        end
        file = transpose(file);
        file = char(file);
    end%


    function hereRemoveUTFBOM( )
        % Remove UTF-8 and UTF-16 bytes order mark from the beginnings of
        % CSV files created sometimes by MS Excel for Mac
        UTF8 = char([239, 187, 191]);
        if strncmp(file, UTF8, numel(UTF8))
            file = file(length(UTF8)+1:end);
        end
        UTF16 = char(65279);
        if strncmp(file, UTF16, 1)
            file = file(2:end);
        end
    end%


    function hereConvertToCell( )
        % Read individual lines into cellstr and remove EOLs
        c = file;
        eol = strfind(c, sprintf('\n'));
        file = cell(1, length(eol)+1);
        posOfEols = [0, eol, length(file)+1];
        for i = 1 : length(posOfEols)-1
            first = posOfEols(i)+1;
            last = posOfEols(i+1)-1;
            file{i} = c(first:last);
        end
    end%
end%

