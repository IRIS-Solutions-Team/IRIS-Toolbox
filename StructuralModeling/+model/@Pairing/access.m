function [output, beenHandled] = access(this, what, quantity)

% >=R2019b
%{
arguments
    this model.Pairing
    what (1, 1) string
    quantity model.Quantity
end
%}
% >=R2019b


    beenHandled = true;
    output = [ ];
    stringify = @(x) reshape(string(x), 1, [ ]);

    F = @(x) erase(lower(x), ["s", "_", "-", ":", "."]);
    what = F(what);

    if what==F("autoswaps-simulate")
        [~, ~, output] = model.Pairing.getAutoswaps(this.Autoswaps.Simulate, quantity, @string);

    elseif what==F("autoswaps-steady")
        [~, ~, output] = model.Pairing.getAutoswaps(this.Autoswaps.Steady, quantity, @string);

    else
        beenHandled = false;

    end

end%

