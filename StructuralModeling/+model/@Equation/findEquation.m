
function [equations, descriptions, aliases] = findEquation(this, varargin)

    numEquations = numel(this.Input);
    inx = true(1, numEquations);
    input = textual.stringify(this.Input);

    for i = 1 : numel(varargin)
        inx = inx & varargin{i}(input);
    end

    equations = input(inx);
    descriptions = textual.stringify(this.Label(inx));
    aliases = textual.stringify(this.Alias(inx));

end%

