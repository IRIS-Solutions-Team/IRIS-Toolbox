function [output, beenHandled] = access(this, what)

% >=R2019b
%(
arguments
    this (1, :) model.component.Quantity
    what (1, 1) string
end
%)
% >=R2019b

what = lower(what);

beenHandled = true;
output = [ ];
allNames = textual.stringify(this.Name);
numQuantities = numel(allNames);
ttrendName = textual.stringify(this.RESERVED_NAME_TTREND);


if endsWith(what, "descriptions")
    allNames = textual.stringify(this.Label);
    what = erase(what, "descriptions");
    if what==""
        what = "names";
    end
end


if what==lower("names")
    output = allNames;
    output(output==ttrendName) = [];

elseif what==lower("measurementVariables")
    output = allNames(this.Type==1);

elseif what==lower("transitionVariables")
    output = allNames(this.Type==2);

elseif what==lower("allShocks")
    output = allNames(this.Type==31 | this.Type==32);

elseif what==lower("transitionShocks")
    output = allNames(this.Type==32);

elseif what==lower("measurementShocks")
    output = allNames(this.Type==31);

elseif what==lower("parameters")
    output = allNames(this.Type==4);

elseif what==lower("exogenousVariables")
    output = allNames(this.Type==5);
    output = setdiff(output, ttrendName, "stable");

elseif what==lower("logVariables")
    inxType = this.Type==1 | this.Type==2; output = stringify(this.Name(this.InxLog & inxType));


elseif any(what==lower(["^logVariables", "nonLogVariables"]))
    inxType = this.Type==1 | this.Type==2;
    output = stringify(this.Name(~this.InxLog & inxType));


elseif any(what==lower(["logStatus", "isLog"]))
    inxType = getIndexByType(this, 1, 2, 5);
    inxType(allNames==ttrendName) = false;
    status = num2cell(reshape(this.InxLog(inxType), 1, []));
    output = cell2struct(status, allNames(inxType), 2);


elseif any(what==lower(["nameDescription", "nameLabel", "namesDescriptions", "nameDescriptionsStruct"]))
    labels = arrayfun(@(x) string(x), this.Label, "uniformOutput", false);
    output = cell2struct(labels, this.Name, 2);


elseif any(what==lower("nameAliasesStruct"))
    output = arrayfun(@(x) string(x), this.Alias, "uniformOutput", false);
    output = cell2struct(output, this.Name, 2);


elseif any(what==lower("nameAttributesStruct"))
    output = cell2struct(this.Attributes, this.Name, 2);


elseif any(what==lower("nameAttributes"))
    output = this.Attributes;


elseif what==lower("positions")
    positions = num2cell(1 : numQuantities);
    output = cell2struct(positions, allNames, 2);


elseif what==lower("nameAttributesList")
    output = unique([this.Attributes{:}], "stable");


else
    beenHandled = false;

end

end%

