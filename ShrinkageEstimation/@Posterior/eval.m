function [mldPoster, mldData, mldIndiePriors, mldSystemPriors] = eval(this, varargin)

if isempty(varargin)
    paramValues = {this.Initial};
else
    paramValues = varargin;
end

numVariants = numel(paramValues);

mldPoster = nan(1, numVariants);
mldData = nan(1, numVariants);
mldIndiePriors = nan(1, numVariants);
mldSystemPriors = nan(1, numVariants);

for i = 1 : numVariants
    if isstruct(paramValues{i})
        temp = paramValues{i};
        paramValues{i} = nan(1, numParameters);
        for j = 1 : numParameters
            paramValues{i}(j) = temp.(this.ParameterNames(j));
        end
    end
    mldPoster(i) = this.ObjectiveFunction(paramValues{i});
end

end%

