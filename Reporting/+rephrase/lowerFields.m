function x = lowerFields(x)
    if ~isstruct(x)
        return
    end

    origFields = reshape(string(fieldnames(x)), 1, []);

    for n = origFields
        if isstruct(x.(n))
            x.(n) = rephrase.lowerFields(x.(n));
        end
    end

    for n = origFields(origFields~=lower(origFields))
        x.(lower(n)) = x.(n);
        x = rmfield(x, n);
    end
end%
