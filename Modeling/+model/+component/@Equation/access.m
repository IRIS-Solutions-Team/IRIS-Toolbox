function [output, handled] = access(this, what)

% >=R2019b
%{
arguments
    this (1, :) model.component.Equation
    what (1, 1) string
end
%}
% >=R2019b

handled = true;
output = [ ];
stringify = @(x) reshape(string(x), 1, [ ]);

if matches(what, "equations", "ignoreCase", true)
    output = stringify(this.Input);

elseif matches(what, "equationsDynamic", "ignoreCase", true)
    output = stringify(this.Input);
    output = model.component.Equation.extractInput(output, "dynamic");

elseif matches(what, "equationsSteady", "ignoreCase", true)
    output = stringify(this.Input);
    output = model.component.Equation.extractInput(output, "steady");

elseif matches(what, "measurementEquations", "ignoreCase", true)
    output = stringify(this.Input(this.Type==1));

elseif matches(what, "transitionEquations", "ignoreCase", true)
    output = stringify(this.Input(this.Type==2));

elseif matches(what, "dtrends", "ignoreCase", true)
    output = stringify(this.Input(this.Type==3));

elseif matches(what, "links", "ignoreCase", true)
    output = stringify(this.Input(this.Type==4));

else
    handled = false;

end

end%


