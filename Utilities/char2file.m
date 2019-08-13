function char2file(c, fileName, varargin)
% char2file  Write character string to text file
%{
% ## Syntax ##
%
% Input arguments marked with a `~` sign may be omitted
%
%     char2file(c, fileName)
%     char2file(c, fileName, ~precision, ...)
%
%
% ## Input Arguments ##
%
% **c** [ char | string ] -
% Character vector or string that will be written to the file.
%
% **fileName** [ char ] -
% Name of the destination file.
%
% **~precision** [ char ] -
% Form and precision of the data written to the file; if omitted,
% `precision='char'`.
%
%
% ## Options ##
%
% **MachineFormat='native'** [ char | string ] 
% Format for writing bytes and bits in the destination file.
%
% **Encoding=@auto** [ `@auto` | char | string ] -
% Encoding scheme for writing in the destination file; `@auto` means the
% operating system default scheme.
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

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
    parser.addRequired('InputString', @validate.string);
    parser.addRequired('FileName', @validate.string);
    parser.addRequired('Precision', @validate.string);
    parser.addParameter('MachineFormat', 'Native', @validate.string);
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

