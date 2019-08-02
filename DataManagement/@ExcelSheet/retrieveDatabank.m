function outputDatabank = retrieveDatabank(this, range, varargin)

persistent parser
if isempty(parser)
    parser = extend.InputParser('ExcelSheet.retrieveDatabank');
    addRequired(parser, 'excelSheet', @(x) isa(x, 'ExcelSheet'));
    addRequired(parser, 'range', @(x) isnumeric(x) || Valid.string(x));
    % Options
    addParameter(parser, 'OutputType', 'struct', @(x) Valid.anyString(x, 'struct', 'Dictionary', 'containers.Map'));
end
parse(parser, this, range, varargin{:});
opt = parser.Options;

%--------------------------------------------------------------------------

if isequaln(this.NamesLocation, NaN)
    THIS_ERROR = { 'ExcelSheet:NamesLocationNotSpecified'
                   'NamesLocation needs to be specified before running retrieveDatabank(~)' };
    throw( exception.Base(THIS_ERROR, 'error') );
end

outputDatabank = hereCreateOutputDatank( );

if this.Orientation=="Row"
    if ~isnumeric(range)
        range = ExcelReference.decodeRowRange(range);
    end
else
    if ~isnumeric(range)
        range = ExcelReference.decodeColumnRange(range);
    end
end
range = transpose(range(:));

for i = range
    name = hereRetrieveName( );
    x = retrieveSeries(this, i);
    hereAddEntryToOutputDatabank(name, x);
end

return

    function outputDatabank = hereCreateOutputDatank( )
        if strcmpi(opt.OutputType, 'struct')
            outputDatabank = struct( );
        elseif strcmpi(opt.OutputType, 'Dictionary')
            outputDatabank = Dictionary( );
        else
            outputDatabank = containers.Map( );
        end
    end%


    function name = hereRetrieveName(location)
        if this.Orientation=="Row"
            name = this.Buffer{location, this.NamesLocation};
        else
            name = this.Buffer{this.NamesLocation, i};
        end
        if isempty(name) || ~Valid.string(name)
            THIS_ERROR = { 'ExcelSheet:InvalidSeriesName'
                           'Some name(s) in NamesLocation are invalid' };
            throw( exception.Base(THIS_ERROR, 'error') );
        end
    end%


    function hereAddEntryToOutputDatabank(name, x)
        if strcmpi(opt.OutputType, 'containers.Map')
            outputDatabank(name) = x;
        else
            outputDatabank = setfield(outputDatabank, name, x);
        end
    end%
end%

