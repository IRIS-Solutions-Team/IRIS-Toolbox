function [output, beenHandled] = access(this, what)

% >=R2019b
%(
arguments
    this (1, :) model.component.Equation
    what (1, 1) string
end
%)
% >=R2019b

beenHandled = true;
output = [ ];
stringify = @(x) reshape(string(x), 1, [ ]);

if lower(what)==lower("equations")
    output = stringify(this.Input);

elseif lower(what)==lower("equationsDynamic")
    output = stringify(this.Input);
    output = model.component.Equation.extractInput(output, "dynamic");

elseif lower(what)==lower("equationsSteady")
    output = stringify(this.Input);
    output = model.component.Equation.extractInput(output, "steady");


elseif lower(what)==lower("measurementEquations")
    output = stringify(this.Input(this.Type==1));


elseif lower(what)==lower("transitionEquations")
    output = stringify(this.Input(this.Type==2));

elseif any(lower(what)==lower(["measurement-trends", "dtrends"]))
    output = stringify(this.Input(this.Type==3));

elseif lower(what)==lower("links")
    output = stringify(this.Input(this.Type==4));


elseif lower(what)==erase("equation-descriptions", "-")
    output = textual.stringify(this.Label);


elseif lower(what)==erase("equation-attributes", "-")
    output = unique([this.Attributes{:}], "stable");


else
    beenHandled = false;

end

end%


