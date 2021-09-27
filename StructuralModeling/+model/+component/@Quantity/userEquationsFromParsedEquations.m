function eqtn = userEquationsFromParsedEquations(this, eqtn)

names = string(this.Name);
eqtn = string(eqtn);
eqtn = regexprep(eqtn, "\<L\((\d+),t(.*?)\)", "&${names(double(string($1)))}{$2}");
eqtn = regexprep(eqtn, "\<x\((\d+),t(.*?)\)", "${names(double(string($1)))}{$2}");
eqtn = erase(eqtn, "{}");

end%

