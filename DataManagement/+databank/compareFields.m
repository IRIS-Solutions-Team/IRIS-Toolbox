function [success, info] = compareFields(d1, d2, opt)

arguments
    d1 (1, 1) {validate.databank(d1)}
    d2 (1, 1) {validate.databank(d2)}
    opt.AbsTol = 1e-12
    opt.Keys = @all
    opt.Error = false
    opt.Warning = false
end

success = true;
info = struct( );
info.FieldNamesMatch = true;
info.ClassesNotEqual = string.empty(1, 0);
info.DimensionsNotEqual = string.empty(1, 0);
info.SeriesStartDatesNotEqual = string.empty(1, 0);
info.SeriesDataNotEqual = string.empty(1, 0);
info.NumericDataNotEqual = string.empty(1, 0);
info.OtherDataNotEqual = string.empty(1, 0);

keys1 = databank.keys(d1);
keys2 = databank.keys(d2);

if isequal(opt.Keys, @all)
    info.FieldNamesMatch = isequal(sort(keys1), sort(keys2));
    keys = keys1;
else
    opt.Keys = reshape(string(opt.Keys), 1, [ ]);
    info.FieldNamesMatch = all(ismember(opt.Keys, keys1)) && all(ismember(opt.Keys, keys2));
    keys = opt.Keys;
end

success = info.FieldNamesMatch;

if success
    for k = keys1
        field1 = d1.(k);
        field2 = d2.(k);
        if ~isequal(class(field1), class(field2))
            info.ClassesNotEqual(end+1) = k;
            success = false;
            continue
        end

        if ~isequal(size(field1), size(field2))
            info.DimensionsNotEqual(end+1) = k;
            success = false;
            continue
        end

        if isa(field1, 'NumericTimeSubscriptable') && isa(field2, 'NumericTimeSubscriptable')
            if ~dater.eq(field1.Start, field2.Start)
                info.SeriesStartDatesNotEqual(end+1) = k;
                success = false;
                continue
            end
            if maxabs(field1.Data, field2.Data)>opt.AbsTol
                info.SeriesDataNotEqual(end+1) = k;
                success = false;
                continue
            end
        elseif isnumeric(field1) && isnumeric(field2)
            if maxabs(field1, field2)>opt.AbsTol
                info.NumericDataNotEqual(end+1) = k;
                success = false;
                continue
            end
        else
            if ~isequaln(field1, field2)
                info.OtherDataNotEqual(end+1) = k;
                success = false;
                continue
            end
        end
    end
end

if ~success
    if isequal(opt.Error, true)
        exception.error([
            "Databank:FieldsFailToMatch"
            "Databank comparison failed."
        ]);
    elseif isequal(opt.Warning, true);
        exception.warning([
            "Databank:FieldsFailToMatch"
            "Databank comparison failed."
        ]);
    end
end

end%

