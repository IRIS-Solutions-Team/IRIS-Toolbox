function [equations, descriptions, aliases] = findEquation(this, filter, varargin)

numEquations = numel(this.Input);
inx = true(1, numEquations);
input = textual.stringify(this.Input);

for i = 1 : numel(varargin)
    inx = inx & filter(input, varargin{i});
end

equations = input(inx);
descriptions = textual.stringify(this.Label(inx));
aliases = textual.stringify(this.Alias(inx));

end%
