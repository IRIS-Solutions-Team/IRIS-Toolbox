function outputDatabank = retrieveDatabank(this, range, varargin)
% retrieveDatabank  Retrieve batch of time series from ExcelSheet into databank
%{
% ## Syntax ##
%
%     outputDatabank = retrieveDatabank(excelSheet, excelRange, ...)
%
%
% ## Input Arguments ##
%
% __`excelSheet`__ [ ExcelSheet ] -
% ExcelSheet object from which the time series will be retrieved and
% returned in an `outputDatabank`; `excelSheet` needs to have its
% `NamesLocation` property assigned.
%
% __`range`__ [ char | string | numeric ] - Excel row range (if the
% ExcelSheet object has Row orientation) or column range (column
% orientation) from which the time series will be retrieved.
%
%
% ## Output Arguments ##
%
% __`outputDataban`__ [ | ] -
% Output databank with the requsted time series.
%
%
% ## Options ##
%
% __`AddToDatabank=[ ]`__ [ empty | struct | Dictionary | containers.Map ] -
% Add the requested time series to an existing databank; the type (Matlab
% class) of this databank needs to be consistent with option `OutputType=`.
%
% __`OutputType='struct'`__ [ `'struct'` | `'Dictionary'` | `'containers.Map'` ] -
% Type (Matlab class) of the output databank.
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


persistent parser
if isempty(parser)
    parser = extend.InputParser('ExcelSheet.retrieveDatabank');
    addRequired(parser, 'excelSheet', @(x) isa(x, 'ExcelSheet'));
    addRequired(parser, 'range', @(x) isnumeric(x) || validate.string(x));
    % Options
    addParameter(parser, 'AddToDatabank', [ ], @(x) isempty(x) || validate.databank(x));
    addParameter(parser, 'OutputType', 'struct', @(x) validate.anyString(x, 'struct', 'Dictionary', 'containers.Map'));
end
parse(parser, this, range, varargin{:});
opt = parser.Options;

%--------------------------------------------------------------------------

if isequaln(this.NamesLocation, NaN)
    THIS_ERROR = { 'ExcelSheet:NamesLocationNotSpecified'
                   'NamesLocation needs to be specified before running retrieveDatabank(~)' };
    throw( exception.Base(THIS_ERROR, 'error') );
end

outputDatabank = databank.backend.ensureTypeConsistency( opt.AddToDatabank, ...
                                                         opt.OutputType );

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
        if isempty(name) || ~validate.string(name)
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

