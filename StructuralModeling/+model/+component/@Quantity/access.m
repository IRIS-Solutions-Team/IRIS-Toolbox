function [output, beenHandled] = access(this, what)

% >=R2019b
%(
arguments
    this (1, :) model.component.Quantity
    what (1, 1) string
end
%)
% >=R2019b

beenHandled = true;
output = [ ];
stringify = @(x) reshape(string(x), 1, [ ]);
allNames = stringify(this.Name);
numQuantities = numel(allNames);
ttrendName = stringify(this.RESERVED_NAME_TTREND);

if lower(what)==lower("names")
    output = allNames;
    output(output==ttrendName) = [];

elseif lower(what)==lower("measurementVariables")
    output = allNames(this.Type==1);

elseif lower(what)==lower("transitionVariables")
    output = allNames(this.Type==2);

elseif lower(what)==lower("shocks")
    output = allNames(this.Type==31 | this.Type==32);

elseif lower(what)==lower("transitionShocks")
    output = allNames(this.Type==32);

elseif lower(what)==lower("measurementShocks")
    output = allNames(this.Type==31);

elseif lower(what)==lower("parameters")
    output = allNames(this.Type==4);

elseif lower(what)==lower("exogenousVariables")
    output = allNames(this.Type==5);
    output = setdiff(output, ttrendName, "stable");

elseif lower(what)==lower("logVariables")
    inxType = this.Type==1 | this.Type==2; output = stringify(this.Name(this.InxLog & inxType));

elseif any(lower(what)==lower(["^logVariables", "nonLogVariables"]))
    inxType = this.Type==1 | this.Type==2;
    output = stringify(this.Name(~this.InxLog & inxType));

elseif lower(what)==lower("logStatus")
    inxType = getIndexByType(this, 1, 2, 5);
    inxType(allNames==ttrendName) = false;
    status = num2cell(reshape(this.InxLog(inxType), 1, []));
    output = cell2struct(status, allNames(inxType), 2);

elseif any(lower(what)==lower(["nameDescription", "nameLabel"]))
    labels = arrayfun(@(x) string(x), this.Label, "uniformOutput", false);
    output = cell2struct(labels, this.Name, 2);

elseif lower(what)==lower("positions")
    positions = num2cell(1 : numQuantities);
    output= cell2struct(positions, allNames, 2);

else
    beenHandled = false;

end

end%

