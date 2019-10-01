function flag = compareFields(d1, d2)

[keys1, keys2] = hereGetKeys( );

if ~isequal(sort(keys1), sort(keys2))
    warning('Number of fields or field names do not match');
    flag = false;
    return
end

for key = keys1
    if isa(d1, 'Dictionary')
        field1 = retrieve(d1, key);
    elseif isstruct(d1)
        field1 = getfield(d1, char(key));
    end
    if isa(d2, 'Dictionary')
        field2 = retrieve(d2, key);
    elseif isstruct(d2)
        field2 = getfield(d2, char(key));
    end
    if isa(field1, 'NumericTimeSubscriptable') && isa(field2, 'NumericTimeSubscriptable')
        if ~isequal(field1.Start, field2.Start)
            warning('Start dates for these fields do not match: %s', key);
            flag = false;
            return
        end
        if ~isequal(field1.Data, field2.Data)
            warning('Time series data for these fields do not match: %s', key);
            flag = false;
            return
        end
    elseif ~isequal(field1, field2)
        warning('This field does not match: %s', key);
        flag = false;
        return
    end
end

flag = true;

return

    function [keys1, keys2] = hereGetKeys( )
        if isa(d1, 'Dictionary')
            keys1 = keys(d1);
        elseif isstruct(d1)
            keys1 = fieldnames(d1);
            keys1 = reshape(string(keys1), 1, [ ]);
        end

        if isa(d2, 'Dictionary')
            keys2 = keys(d2);
        elseif isstruct(d2)
            keys2 = fieldnames(d2);
            keys2 = reshape(string(keys2), 1, [ ]);
        end
    end%
end%

