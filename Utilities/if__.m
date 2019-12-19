function output = if__(left, func, right, outputTrue, outputFalse)
% if__  Runtime if condition

if nargin<3
    outputFalse = 0;
end

condition = feval(func, left, right);

numConditions = numel(condition);
numOutputTrue = numel(outputTrue);
numOutputFalse = numel(outputFalse);
if numConditions>1 & numOutputTrue==1
    outputTrue = repmat(outputTrue, size(condition));
    numOutputTrue = numel(outputTrue);
end
if numConditions>1 & numOutputFalse==1
    outputFalse = repmat(outputFalse, size(condition));
    numOutputFalse = numel(outputFalse);
end

output = outputTrue;
if any(~condition)
    output(~condition) = outputFalse(~condition);
end

end%

