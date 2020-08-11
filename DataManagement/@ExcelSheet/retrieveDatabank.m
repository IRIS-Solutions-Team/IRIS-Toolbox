function outputDb = retrieveDatabank(this, range, varargin)
% retrieveDatabank  Retrieve batch of time series from ExcelSheet into databank
%{
% ## Syntax ##
%
%     outputDb = retrieveDatabank(excelSheet, excelRange, ...)
%
%
% ## Input Arguments ##
%
% __`excelSheet`__ [ ExcelSheet ] -
% ExcelSheet object from which the time series will be retrieved and
% returned in an `outputDb`; `excelSheet` needs to have its
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

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('ExcelSheet.retrieveDatabank');
    addRequired(pp, 'excelSheet', @(x) isa(x, 'ExcelSheet'));
    addRequired(pp, 'range', @(x) isnumeric(x) || isstring(x) || validate.string(x));
    
    addParameter(pp, 'AddToDatabank', [ ], @(x) isempty(x) || validate.databank(x));
    addParameter(pp, 'OutputType', 'struct', @(x) validate.anyString(x, 'struct', 'Dictionary'));
    addParameter(pp, "UpdateWhenExists", false, @validate.logicalScalar);
end
%)
opt = parse(pp, this, range, varargin{:});

%--------------------------------------------------------------------------

names = [ ];
if isstring(range) && numel(range)>1 && all(contains(range, "->"))
    [range, names] = textual.split(range, "->"); 
    range = strip(range);
    names = strip(names);
end

if isequaln(this.NamesLocation, NaN) && isempty(names)
    exception.error([
        "ExcelSheet:NamesLocationNotSpecified"
        "The ExcelSheet property NamesLocation needs to be specified first "
        "when running retrieveDatabank( ) without the reference->name mapping."
    ]);
end

outputDb = databank.backend.ensureTypeConsistency( ...
    opt.AddToDatabank, opt.OutputType ...
);

if this.Orientation=="Row"
    if isstring(range) && numel(range)>1
        range = ExcelReference.decodeRow(range);
    elseif ~isnumeric(range)
        range = ExcelReference.decodeRowRange(range);
    end
else
    if isstring(range) && numel(range)>1
        range = ExcelReference.decodeColumn(range);
    elseif ~isnumeric(range)
        range = ExcelReference.decodeColumnRange(range);
    end
end
range = reshape(range, 1, [ ]);

for i = 1 : numel(range)
    if ~isempty(names)
        name = names(i);
    else
        name = hereRetrieveName(range(i));
    end
    x = retrieveSeries(this, range(i));
    hereAddEntryToOutputDatabank(name, x);
end

return

    function outputDb = hereCreateOutputDatank( )
        if strcmpi(opt.OutputType, 'Dictionary')
            outputDb = Dictionary( );
        else
            outputDb = struct( );
        end
    end%


    function name = hereRetrieveName(location)
        if this.Orientation=="Row"
            name = this.Buffer{location, this.NamesLocation};
        else
            name = this.Buffer{this.NamesLocation, location};
        end
        if isempty(name) || ~validate.string(name)
            exception.error([
                "ExcelSheet:InvalidSeriesName"
                "Some name(s) in NamesLocation are invalid."
            ]);
        end
    end%


    function hereAddEntryToOutputDatabank(name, newSeries)
        if opt.UpdateWhenExists && isfield(outputDb, name) && ~isempty(outputDb.(name))
            if matches(opt.OutputType, "Dictionary", "ignoreCase", true)
                updateSeries(outputDb, name, newSeries);
            else
                outputDb.(name) = [outputDb.(name); newSeries];
            end
        else
            if matches(opt.OutputType, "Dictionary", "ignoreCase", true)
                store(outputDb, name, newSeries);
            else
                outputDb.(name) = newSeries;
            end
        end
    end%
end%

