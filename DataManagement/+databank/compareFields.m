function flag = compareFields(d1, d2)

[keys1, keys2] = hereGetKeys( );

if ~isequal(sort(keys1), sort(keys2))
    warning('Number of fields or field names do not match');
    flag = false;
    return
end

for i = 1 : numel(keys1)
    key__ = keys1{i};
    field1 = d1.(key__);
    field2 = d2.(key__);
    if isa(field1, 'NumericTimeSubscriptable') && isa(field2, 'NumericTimeSubscriptable')
        if ~isequal(field1.Start, field2.Start)
            warning('Start dates for these fields do not match: %s', key__);
            flag = false;
            return
        end
        if ~isequal(field1.Data, field2.Data)
            warning('Time series data for these fields do not match: %s', key__);
            flag = false;
            return
        end
    elseif ~isequal(field1, field2)
        warning('This field does not match: %s', key__);
        flag = false;
        return
    end
end

flag = true;

return

    function [keys1, keys2] = hereGetKeys( )
        keys1 = fieldnames(d1);
        keys1 = reshape(cellstr(keys1), 1, [ ]);

        keys2 = fieldnames(d2);
        keys2 = reshape(cellstr(keys2), 1, [ ]);
    end%
end%

