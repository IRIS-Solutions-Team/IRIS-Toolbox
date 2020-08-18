function [response, isValid, query] = implementGet(this, query, quantity, varargin)

TYPE = @int8; %#ok<NASGU>
response = [ ];
isValid = true;

if startsWith(query, "Gradients", "IgnoreCase", true)
    response = this;
    numEquations = size(response.Dynamic, 2);
    for i = 1 : numEquations
        response.Dynamic{2, i} = printVector(quantity, response.Dynamic{2, i}, "");
        response.Steady{2, i} = printVector(quantity, response.Steady{2, i}, "");
    end
    response.Dynamic = transpose(response.Dynamic);
    response.Steady = transpose(response.Steady);


else
    isValid = false;

end

end%

