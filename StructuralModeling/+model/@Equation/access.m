function [output, beenHandled] = access(this, what)

% >=R2019b
%{
arguments
    this (1, :) model.Equation
    what (1, 1) string
end
%}
% >=R2019b


beenHandled = true;
output = [ ];
stringify = @(x) reshape(string(x), 1, [ ]);

F = @(x) erase(lower(x), ["s", "_", "-", ":", "."]);
what = F(what);

if what==F("equations")
    output = stringify(this.Input);

elseif what==F("equations-dynamic")
    output = stringify(this.Input);
    output = model.Equation.extractInput(output, "dynamic");

elseif what==F("equations-steady")
    output = stringify(this.Input);
    output = model.Equation.extractInput(output, "steady");

elseif what==F("measurement-equations")
    output = stringify(this.Input(this.Type==1));

elseif what==F("transition-equations")
    output = stringify(this.Input(this.Type==2));

elseif any(what==F(["measurement-trends", "dtrends"]))
    output = stringify(this.Input(this.Type==3));

elseif what==F("links")
    output = stringify(this.Input(this.Type==4));

elseif what==F("equations-descriptions")
    output = textual.stringify(this.Label);

elseif what==F("equations-attributes")
    output = unique([this.Attributes{:}], "stable");

else
    beenHandled = false;

end

end%

