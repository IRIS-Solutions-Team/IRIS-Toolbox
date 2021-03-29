function [output, beenHandled] = access(this, what)

% >=R2019b
%(
arguments
    this (1, :) model.component.Quantity
    what (1, 1) string
end
%)
% >=R2019b

TYPE = @int8;

beenHandled = true;
output = [ ];
stringify = @(x) reshape(string(x), 1, [ ]);

if matches(what, "names", "ignoreCase", true)
    output = stringify(this.Name);
    output = setdiff(output, this.RESERVED_NAME_TTREND, "stable");

elseif matches(what, "measurementVariables", "ignoreCase", true)
    output = stringify(this.Name(this.Type==1));

elseif matches(what, "transitionVariables", "ignoreCase", true)
    output = stringify(this.Name(this.Type==2));

elseif matches(what, "shocks", "ignoreCase", true)
    output = stringify(this.Name(this.Type==31 | this.Type==32));

elseif matches(what, "transitionShocks", "ignoreCase", true)
    output = stringify(this.Name(this.Type==32));

elseif matches(what, "measurementShocks", "ignoreCase", true)
    output = stringify(this.Name(this.Type==31));

elseif matches(what, "parameters", "ignoreCase", true)
    output = stringify(this.Name(this.Type==4));

elseif matches(what, "exogenousVariables", "ignoreCase", true)
    output = stringify(this.Name(this.Type==5));
    output = setdiff(output, this.RESERVED_NAME_TTREND, "stable");

elseif matches(what, "logVariables", "ignoreCase", true)
    inxType = this.Type==TYPE(1) | this.Type==TYPE(2);
    output = stringify(this.Name(this.InxLog & inxType));

elseif matches(what, ["^logVariables", "nonLogVariables"], "ignoreCase", true)
    inxType = this.Type==TYPE(1) | this.Type==TYPE(2);
    output = stringify(this.Name(~this.InxLog & inxType));

elseif matches(what, "logStatus", "ignoreCase", true)
    inxType = this.Type==1 | this.Type==2;
    names = stringify(this.Name(inxType))
    status = num2cell(reshape(this.InxLog(inxType), 1, []));
    output = cell2struct(status, names, 2);

elseif startsWith(what, ["nameDescription", "nameLabel"], "ignoreCase", true)
    labels = arrayfun(@(x) string(x), this.Label, "uniformOutput", false);
    output = cell2struct(labels, this.Name, 2);

else
    beenHandled = false;

end

end%

