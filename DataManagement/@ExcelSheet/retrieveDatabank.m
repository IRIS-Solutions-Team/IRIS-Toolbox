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
% __`AddToDatabank=[ ]`__ [ empty | struct | Dictionary ] -
% Add the requested time series to an existing databank; the type (Matlab
% class) of this databank needs to be consistent with option `OutputType=`.
%
% __`OutputType='struct'`__ [ `'struct'` | `'Dictionary'` ] -
% Type (Matlab class) of the output databank.
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

persistent pp
if isempty(pp)
    pp = extend.InputParser('ExcelSheet.retrieveDatabank');
    addRequired(pp, 'excelSheet', @(x) isa(x, 'ExcelSheet'));
    addRequired(pp, 'range', @(x) isnumeric(x) || validate.string(x));
    % Options
    addParameter(pp, 'AddToDatabank', [ ], @(x) isempty(x) || validate.databank(x));
    addParameter(pp, 'OutputType', 'struct', @(x) validate.anyString(x, 'struct', 'Dictionary'));
end
parse(pp, this, range, varargin{:});
opt = pp.Options;

%--------------------------------------------------------------------------

if isequaln(this.NamesLocation, NaN)
    thisError = [
        "ExcelSheet:NamesLocationNotSpecified"
        "The ExcelSheet property NamesLocation needs to be specified "
        "before running retrieveDatabank( )."
    ];
    throw( exception.Base(thisError, 'error') );
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
        if strcmpi(opt.OutputType, 'Dictionary')
            outputDatabank = Dictionary( );
        else
            outputDatabank = struct( );
        end
    end%


    function name = hereRetrieveName(location)
        if this.Orientation=="Row"
            name = this.Buffer{location, this.NamesLocation};
        else
            name = this.Buffer{this.NamesLocation, i};
        end
        if isempty(name) || ~validate.string(name)
            thisError = [
                "ExcelSheet:InvalidSeriesName"
                "Some name(s) in NamesLocation are invalid."
            ];
            throw( exception.Base(thisError, 'error') );
        end
    end%


    function hereAddEntryToOutputDatabank(name, x)
        if strcmpi(opt.OutputType, 'Dictionary')
            store(outputDatabank, name, x);
        else
            outputDatabank.(char(name)) = x;
        end
    end%
end%

