%{
% 
% # `analyticGradients` ^^(Model)^^
% 
% {== Evaluate analytic/symbolic derivatives of model equations ==}
% 
% 
% ## Syntax
% 
%     [dynamic, steady] = analyticGradients(model)
% 
% 
% ## Input arguments
% 
% __`model`__ [ Model ]
% > 
% > Model object whose equations will be analytically/symbolically
% > differentiated w.r.t to the model variables present in the respective
% > equation.
% > 
% 
% ## Output arguments
% 
% __`dynamic`__ [ cell ]
% > 
% > A cell array with the derivatives of the dynamic versions of the model
% >   equations w.r.t. the variables present in each respective equation
% > 
% > See Description for details.
% > 
% 
% __`steady`__ [ cell ]
% > 
% > A cell array with the derivatives of the steady versions of the model
% > equations (if provided by the user) w.r.t. the variables present in each
% > respective equation
% > 
% > See Description for details.
% > 
% 
% ## Description
% 
% Each of the `dynamic` and `steady` output arguments is a 2-by-N
% cell array, where N is the number of equations in the model (counting also
% measurement trends and dynamic links); the `{1, i}` element is a 1-by-K array of
% strings with the analytic/symbolic derivatives of the i-th equation
% w.r.t. a total of K variables (including their lags and leads) that are
% present in the respective equation. The list of the K variables in then in
% the `{2, i}` element.
% 
% If an equation does not have a steady-state version, the corresponding
% elements of the `steady` cell array are returned empty.
% 
% 
% ## Examples
% 
% 
%}
% --8<--


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

