function [output, handled] = access(this, what)

arguments
    this (1, :) model.component.Quantity
    what (1, 1) string
end

handled = true;
output = [ ];
stringify = @(x) reshape(string(x), 1, [ ]);

what = erase(what, ["_", "-", ":", "."]);

if matches(what, "measurementVariables", "ignoreCase", true)
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

elseif matches(what, "logVariables", "ignoreCase", true)
    output = stringify(this.Name(this.InxLog));

elseif matches(what, "nonLogVariables", "ignoreCase", true)
    output = stringify(this.Name(~this.InxLog));

elseif matches(what, "logStatus", "ignoreCase", true)
    inx = this.Type==1 | this.Type==2;
    names = stringify(this.Name(inx))
    status = reshape(this.InxLog(inx), 1, [ ]);
    output = cell2struct( ...
        mat2cell(status, 1, ones(size(status))), names, 2 ...
    );

else
    handled = false;

end

end%

