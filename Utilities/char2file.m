function char2file(c, fileName, varargin)
% char2file  Write character string to text file
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted
%
%     char2file(c, fileName)
%     char2file(c, fileName, ~precision, ...)
%
%
% __Input Arguments__
%
% __`c`__ [ char | string ] –
% Character vector or string that will be written to the file.
%
% __`fileName`__ [ char ] –
% Name of the destination file.
%
% __`~precision`__ [ char ] –
% Form and precision of the data written to the
% file; if omitted, `precision='char'`.
%
%
% __Options__
%
% __`MachineFormat='native'`__ [ char | string ] 
% rder for writing bytes
% and bits in the destination file.
%
% __`Encoding=@auto`__ [ `@auto` | char | string ] –
% Encoding scheme for writing in the destination file; `@auto` means the
% operating system default scheme.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

if nargin<3
    precision = 'char';
else
    precision = varargin{1};
    varargin(1) = [ ];
end

persistent parser
if isempty(parser)
    parser = extend.InputParser('char2file');
    parser.addRequired('InputString', @Valid.string);
    parser.addRequired('FileName', @Valid.string);
    parser.addRequired('Precision', @Valid.string);
    parser.addParameter('MachineFormat', 'Native', @Valid.string);
    parser.addParameter('Encoding', @auto, @(x) isequal(x, @auto) || Valid.string(x));
end
parse(parser, c, fileName, precision, varargin{:});
opt = parser.Options;

%--------------------------------------------------------------------------

fid = hereOpenFile( );

if iscellstr(c)
    hereConvertToChar( );
end

hereWriteToFile( );

fclose(fid);

return


    function fid = hereOpenFile( )
        if isequal(opt.Encoding, @auto)
            fid = fopen(fileName, 'w+', opt.MachineFormat);
        else
            fid = fopen(fileName, 'w+', opt.MachineFormat, opt.Encoding);
        end
        if fid==-1
            THIS_ERROR = { 'CannotOpenFileForWriting'
                           'Cannot open this file for writing: %s ' };
            throw( exception.Base(THIS_ERROR, 'error'), ...
                   fileName );
        end
    end%


    function hereConvertToChar( )
        c = sprintf('%s\n', c{:});
        if ~isempty(c)
            c(end) = '';
        end
    end%


    function hereWriteToFile( )
        skip = 0;
        count = fwrite(fid, c, precision, skip, opt.MachineFormat);
        if count~=length(c)
            fclose(fid);
            THIS_ERROR = { 'CannotWriteToFile'
                           'Cannot write character string to this file: %s ' };
            throw( exception.Base(THIS_ERROR, 'error'), ...
                   fileName );
        end
    end%
end%

