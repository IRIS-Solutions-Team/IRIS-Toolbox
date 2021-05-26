function write(c, fileName, varargin)

if nargin<3
    precision = 'char';
else
    precision = varargin{1};
    varargin(1) = [];
end

persistent parser
if isempty(parser)
    parser = extend.InputParser();
    parser.addRequired('inputString', @validate.string);
    parser.addRequired('fileName', @validate.string);
    parser.addRequired('precision', @validate.string);
    parser.addParameter('MachineFormat', 'Native', @validate.string);
    parser.addParameter('Encoding', @auto, @(x) isequal(x, @auto) || validate.string(x));
end
parse(parser, c, fileName, precision, varargin{:});
opt = parser.Options;

%--------------------------------------------------------------------------

fid = locallyOpenFile(fileName, opt);

try
    c = string(c);
    if numel(c)>1
        c = join(c, string(newline()));
    end
    locallyWriteToFile(c, fid, fileName, precision, opt);
catch mexp
    fclose(fid);
    rethrow(mexp);
end

fclose(fid);

end%

%
% Local functions
%

function fid = locallyOpenFile(fileName, opt)
    %(
    if isequal(opt.Encoding, @auto)
        fid = fopen(fileName, "w+", opt.MachineFormat);
    else
        fid = fopen(fileName, "w+", opt.MachineFormat, opt.Encoding);
    end
    if fid==-1
        exception.error([
            "FileOpening:CannotOpenFileForWriting"
            "Cannot open this file for writing: %s"
        ], fileName);
    end
    %)
end%


function success = locallyWriteToFile(c, fid, fileName, precision, opt)
    %(
    skip = 0;
    count = fwrite(fid, c, precision, skip, opt.MachineFormat);
    success = count==strlength(c);
    if ~success
        exception.error([
            "WriteFile:CannotWriteToFile"
            "Cannot write text to this file: %s"
        ]);
    end
    %)
end%

