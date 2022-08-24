function [flag, list, inxInvalidLevel, inxInvalidGrowth] = checkZeroLog(this, variantsRequested)

if nargin<2
    variantsRequested = ':';
end

%--------------------------------------------------------------------------

inxLog = this.Quantity.InxLog;
level = real(this.Variant.Values(:, :, variantsRequested));
growth = imag(this.Variant.Values(:, :, variantsRequested));

inxInvalidLevel = bsxfun(@and, inxLog, level<=this.Tolerance.Steady);
inxInvalidLevelReport = any(inxInvalidLevel, 3);

inxInvalidGrowth = bsxfun(@and, inxLog, growth<0);
inxInvalidGrowthReport = any(inxInvalidGrowth, 3);

flag = ~any(inxInvalidLevelReport) && ~any(inxInvalidGrowthReport);
list = cell.empty(1, 0);
if flag
    return
end

if any(inxInvalidLevelReport)
    listLevel = this.Quantity.Name(inxInvalidLevelReport);
    thisError = [ 
        "Model:InvalidSteadyLogVariable"
        "Steady-state level of this log variable is zero or negative: %s"
    ];
    throw(exception.Base(thisError, 'warning'), listLevel{:});
    list = [list, listLevel];
end

if any(inxInvalidGrowthReport)
    listGrowth = this.Quantity.Name(inxInvalidGrowthReport);
    thisError = [ 
        "Model:InvalidSteadyLogVariable"
        "Steady-state rate of change of this log variable is zero or negative: %s"
    ];
    throw(exception.Base(thisError, 'warning'), listGrowth{:});
    list = [list, listGrowth];
end

if ~isempty(list)
    list = unique(list, 'stable');
end

end%

