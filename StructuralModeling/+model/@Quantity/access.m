function [output, beenHandled] = access(this, what)

% >=R2019b
%{
arguments
    this (1, :) model.Quantity
    what (1, 1) string
end
%}
% >=R2019b


what = lower(what);

beenHandled = true;
output = [ ];
allNames = textual.stringify(this.Name);
numQuantities = numel(allNames);
ttrendName = textual.stringify(this.RESERVED_NAME_TTREND);
F = @(x) erase(lower(x), ["s", "_", "-", ":", "."]);
what = F(what);

if what==F("names")
    output = allNames;
    output(output==ttrendName) = [];

elseif what==F("measurement-variables")
    output = allNames(this.Type==1);

elseif what==F("transition-variables")
    output = allNames(this.Type==2);

elseif what==F("all-shocks")
    output = allNames(this.Type==31 | this.Type==32);

elseif what==F("transition-shocks")
    output = allNames(this.Type==32);

elseif what==F("measurement-shocks")
    output = allNames(this.Type==31);

elseif what==F("parameters")
    output = allNames(this.Type==4);

elseif what==F("exogenous-variables")
    output = allNames(this.Type==5);
    output = setdiff(output, ttrendName, "stable");

elseif what==F("log-variables")
    inxType = this.Type==1 | this.Type==2; output = textual.stringify(this.Name(this.InxLog & inxType));


elseif any(what==F(["^log-variables", "non-log-variables"]))
    inxType = this.Type==1 | this.Type==2;
    output = textual.stringify(this.Name(~this.InxLog & inxType));


elseif any(what==F(["log-status", "is-log"]))
    inxType = getIndexByType(this, 1, 2, 5);
    inxType(allNames==ttrendName) = false;
    status = num2cell(reshape(this.InxLog(inxType), 1, []));
    output = cell2struct(status, cellstr(allNames(inxType)), 2);


elseif any(what==F(["names-descriptions", "names-labels", "names-descriptions", "names-descriptions-struct"]))
    labels = arrayfun(@(x) string(x), this.Label, 'uniformOutput', false);
    output = cell2struct(labels, cellstr(this.Name), 2);


elseif any(what==F(["shocks-descriptions"]))
    inxType = getIndexByType(this, 31, 32);
    output = string(this.Label(inxType));


elseif any(what==F("names-aliases"))
    output = arrayfun(@(x) string(x), this.Alias, "uniformOutput", false);
    output = cell2struct(output, cellstr(this.Name), 2);


elseif any(what==F("names-attributes"))
    output = cell2struct(this.Attributes, cellstr(this.Name), 2);


elseif any(what==F(["names-positions", "positions"]))
    positions = num2cell(1 : numQuantities);
    output = cell2struct(positions, cellstr(allNames), 2);


elseif any(what==F("names-types"))
    types = repmat("", size(this.Type));
    types(this.Type==1) = "measurement-variables";
    types(this.Type==2) = "transition-variables";
    types(this.Type==31) = "measurement-shocks";
    types(this.Type==32) = "transition-shocks";
    types(this.Type==4) = "parameters";
    types(this.Type==5) = "exogenous-variables";
    types = num2cell(types);
    output = cell2struct(types, celstr(allNames), 2);


elseif what==F("names-attributes-list")
    output = unique([this.Attributes{:}], "stable");


else
    beenHandled = false;

end

end%

