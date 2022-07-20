function [this, success, outputInfo] = steadyUser(this, variantsRequested, userFunc)

    numVariants = countVariants(this);
    if isequal(variantsRequested, Inf)
        variantsRequested = 1 : numVariants;
    end

    inx = getIndexByType(this.Quantity, 1, 2, 4, 5);
    names = string(this.Quantity.Name(inx));
    logStatus = this.Quantity.InxLog(inx);

    for v = reshape(variantsRequested, 1, [])
        currValues = this.Variant.Values(1, inx, v);
        currentStruct = cell2struct(num2cell(currValues), cellstr(names), 2);

        newStruct = userFunc(currentStruct);

        newValues = currValues;
        for i = 1 : numel(names)
            if isfield(newStruct, names(i))
                newValues(1, i, :) = newStruct.(names(i));
            end
        end

        inxFix = imag(newValues)==0 & logStatus;
        newValues(inxFix) = newValues(inxFix) + 1i;
        this.Variant.Values(1, inx, v) = newValues;
    end

    % Reset steady state for time trend
    pos = locateTrendLine(this.Quantity, NaN);
    this.Variant.Values(1, pos, :) = complex(0, 1);

    success = true(1, numVariants);
    outputInfo = struct();

end%

