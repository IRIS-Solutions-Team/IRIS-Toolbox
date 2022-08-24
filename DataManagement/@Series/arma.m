function X = arma(X, E, AR, MA, Range)

validate.mustBeProperRange(Range);

AR = reshape(AR, 1, []);
if isempty(AR)
    AR = 1;
elseif AR(1)~=1
    AR = AR / AR(1);
end

MA = reshape(MA, 1, []);
if isempty(MA)
    MA = 1;
end

%--------------------------------------------------------------------------

pa = numel(AR) - 1;
pm = numel(MA) - 1;
p = max(pa, pm);

nPer = numel(Range);
xRange = Range(1)-p : Range(end);
nXPer = numel(xRange);

XData = getDataFromTo(X, xRange);
EData = getDataFromTo(E, xRange);
EData(isnan(EData)) = 0;
for t = p+1 : nXPer
    XData(t, :) = ...
        -AR(2:end)*XData(t-1:-1:t-pa, :) ...
        + MA*EData(t:-1:t-pm, :);
end

XData(1:end-nPer-pa, :) = [ ];
X = replace(X, XData, Range(1)-pa);

end

