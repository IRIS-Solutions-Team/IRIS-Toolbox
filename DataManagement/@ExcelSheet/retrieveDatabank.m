function outputDb = retrieveDatabank(this, range, varargin)

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('ExcelSheet.retrieveDatabank');
    addRequired(pp, 'excelSheet', @(x) isa(x, 'ExcelSheet'));
    addRequired(pp, 'excelRange', @(x) isnumeric(x) || isstring(x) || validate.string(x));
    
    addParameter(pp, 'AddToDatabank', [ ], @(x) isempty(x) || validate.databank(x));
    addParameter(pp, "NameFunc", [ ], @(x) isempty(x) || isa(x, 'function_handle'));
    addParameter(pp, 'OutputType', @auto, @(x) isequal(x, @auto) || validate.databankType(x));
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

outputDb = databank.backend.ensureTypeConsistency(opt.AddToDatabank, opt.OutputType);

if startsWith(this.Orientation, "row", "ignoreCase", true)
    if isstring(range) && numel(range)>1
        range = ExcelReference.decodeRow(range);
    elseif ~isnumeric(range)
        range = ExcelReference.decodeRowRange(range, size(this.Buffer));
    end
else
    if isstring(range) && numel(range)>1
        range = ExcelReference.decodeColumn(range);
    elseif ~isnumeric(range)
        range = ExcelReference.decodeColumnRange(range, size(this.Buffer));
    end
end
range = reshape(range, 1, [ ]);

invalidNames = string.empty(1, 0);
for i = 1 : numel(range)
    if ~isempty(names)
        name = names(i);
    else
        [name, isMissing, isValid] = hereRetrieveName(range(i));
        if isMissing
            continue
        end
        if ~isValid
            invalidNames(end+1) = string(name);
            continue
        end
    end
    comment = hereRetrieveComment(range(i));
    x = retrieveSeries(this, range(i));
    x.Comment = comment;
    hereAddEntryToOutputDatabank(name, x);
end

if ~isempty(invalidNames)
    exception.warning([
        "ExcelSheet:InvalidSeriesName"
        "This name in NamesLocation is not a valid name and has not been "
        "created in the output databank: %s"
    ], invalidNames);
end

return

    function [name, isMissing, isValid] = hereRetrieveName(location)
        %(
        if startsWith(this.Orientation, "row", "ignoreCase", true)
            name = this.Buffer{location, this.NamesLocation};
        else
            name = this.Buffer{this.NamesLocation, location};
        end
        name = string(name);
        isMissing = ismissing(name) || isempty(name);
        if isMissing
        isValid = false;
            return
        end
        isValid = validate.string(name);
        if ~isValid
            return
        end
        if ~isempty(opt.NameFunc)
            name = opt.NameFunc(name);
        end
        isValid = ~isstruct(outputDb) || isvarname(name);
        %)
    end%


    function comment = hereRetrieveComment(location)
        %(
        if isempty(this.CommentsLocation) || ~isscalar(this.CommentsLocation) || ismissing(this.CommentsLocation)
            comment = "";
            return
        end

        if startsWith(this.Orientation, "row", "ignoreCase", true)
            comment = this.Buffer{location, this.CommentsLocation};
        else
            comment = this.Buffer{this.CommentsLocation, location};
        end
        comment = string(comment);
        if all(ismissing(comment)) || isempty(comment) || all(strlength(comment)==0)
            comment = "";
        end
        %)
    end%


    function hereAddEntryToOutputDatabank(name, newSeries)
        %(
        if opt.UpdateWhenExists && isfield(outputDb, name) && ~isempty(outputDb.(name))
            if isstruct(outputDb)
                outputDb.(name) = [outputDb.(name); newSeries];
            else
                updateSeries(outputDb, name, newSeries);
            end
        else
            if isstruct(outputDb)
                outputDb.(name) = newSeries;
            else
                store(outputDb, name, newSeries);
            end
        end
        %)
    end%
end%

