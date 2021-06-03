function [output, beenHandled] = access(this, what, quantity)

% >=R2019b
%(
arguments
    this model.component.Pairing
    what (1, 1) string
    quantity model.component.Quantity
end
%)
% >=R2019b


beenHandled = true;
output = [ ];
stringify = @(x) reshape(string(x), 1, [ ]);

if lower(what)==lower("autoswapsSimulate")
    [~, ~, output] = model.component.Pairing.getAutoswaps(this.Autoswaps.Simulate, quantity, @string);

elseif lower(what)==lower("autoswapsSteady")
    [~, ~, output] = model.component.Pairing.getAutoswaps(this.Autoswaps.Steady, quantity, @string);

else
    beenHandled = false;

end

end%

