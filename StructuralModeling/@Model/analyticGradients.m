function [dynamic, steady] = analyticGradients(this)

temp = struct();
temp.Symbolic = true;
temp.DiffOutput = "cell";
g = differentiate(this, temp);

output = struct();
output.Dynamic = g.Dynamic(1:2, :);
output.Steady = g.Steady(1:2, :);

logStyle = "none";
for n = ["Dynamic", "Steady"]
    for i = 1 : size(output.(n), 2)
        if isempty(output.(n){1, i})
            output.(n){1, i} = string.empty(1, 0);
            output.(n){2, i} = string.empty(1, 0);
        else
            output.(n){1, i} = erase(string(output.(n){1, i}), " ");
            output.(n){1, i} = userEquationsFromParsedEquations(this.Quantity, output.(n){1, i});
            output.(n){2, i} = printVector(this.Quantity, output.(n){2, i}, logStyle);
        end
    end
end

dynamic = output.Dynamic;
steady = output.Steady;

end%

