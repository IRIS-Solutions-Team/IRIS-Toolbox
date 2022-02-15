function varargout = split(input, varargin)

input = string(input);
sizeInput = size(input);
input = reshape(input, 1, [ ]);
temp = split(input, varargin{:});
if isscalar(input)
    numOutputs = numel(temp);
    varargout = cell(1, numOutputs);
    for i = 1 : numOutputs
        varargout{i} = temp(i);
    end
else
    numOutputs = size(temp, 3);
    varargout = cell(1, numOutputs);
    for i = 1 : numOutputs
        varargout{i} = reshape(temp(:, :, i), sizeInput);
    end
end

end%



