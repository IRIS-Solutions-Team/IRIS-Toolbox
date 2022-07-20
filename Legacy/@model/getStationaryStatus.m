function [status, output] = getStationaryStatus(this, flag, extra)

try
    flag;
catch
    flag = true;
end

try
    extra;
catch
    extra = "";
end


tolerance = this.Tolerance.Eigen;
[~, ~, numXiB, numXiF] = sizeSolution(this.Vector);
vecYXi = [this.Vector.Solution{1:2}];
inxCurrent = imag(vecYXi)==0;
vecYXiCurrent = vecYXi(inxCurrent);
inxE = this.Quantity.Type==31 | this.Quantity.Type==32;

nv = countVariants(this);
numQuantities = numel(this.Quantity.Name);

status = nan(numQuantities, nv);

[~, inxNaSolutions] = isnan(this, 'solution');
for v = find(~inxNaSolutions)
    inxUnitRoots = this.Variant.EigenStability(:, 1:numXiB, v)==1;
    dy = any(abs(this.Variant.FirstOrderSolution{4}(:, inxUnitRoots, v))>tolerance, 2);
    df = any(abs(this.Variant.FirstOrderSolution{1}(1:numXiF, inxUnitRoots, v))>tolerance, 2);
    db = any(abs(this.Variant.FirstOrderSolution{7}(:, inxUnitRoots, v))>tolerance, 2);
    d = [dy; df; db];

    status(vecYXiCurrent, v) = double(~d(inxCurrent));
end

status(inxE, :) = 1;

if ~flag
    inxZero = status==0;
    inxOne = status==1;
    status(inxZero) = 1;
    status(inxOne) = 0;
end

switch extra
    case "list"
        output = cell(1, nv);
        for vv = 1 : nv
            names = textual.stringify(this.Quantity.Name);
            output{vv} = names(status(:, vv)==1);
            output{vv} = reshape(output{vv}, 1, []);
        end
        if nv==1
            output = output{1};
        end
    case "struct"
        names = reshape(cellstr(this.Quantity.Name), [], 1);
        output = cell2struct(num2cell(status, 2), cellstr(names), 1);
    otherwise
        output = [];
end

end%

