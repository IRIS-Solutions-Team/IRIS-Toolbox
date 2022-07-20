% myparse  Post-parse rpteq input code
%
% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

function this = postparse(this, equation, euc)

isnumericscalar = @(x) isnumeric(x) && isscalar(x);

ixr = equation.Type==6;
if ~any(ixr)
    return
end
numOfEquations = numel(equation.Input);

ixValid = true(1, numOfEquations);
for i = find(ixr)
    ixValid(i) = isvarname(euc.LhsDynamic{i});
end
if any(~ixValid)
    throw( exception.Base('RptEq:INVALID_LHS', 'error'), ...
        equation.Input{~ixValid} );
end

this.UsrEqtn = equation.Input(ixr);
this.NamesOfLhs = euc.LhsDynamic(ixr);
this.Label = equation.Label(ixr);
this.MaxSh = max( euc.MaxShDynamic(ixr) );
this.MinSh = min( euc.MinShDynamic(ixr) );
rhs = euc.RhsDynamic(ixr);

% Add prefix `?` and suffix `(:,t)` to names (or names with curly braces)
% not followed by opening bracket or dot and not preceded by exclamation
% mark. The result is `?x#` or `?x{@-k}#`.
rhs = regexprep(rhs, ...
    '(?<!!)(\<[a-zA-Z]\w*\>(\{.*?\})?)(?![\(\.])', '?$1#');

% Vectorize *, /, \, ^ operators
rhs = textfun.vectorize(rhs);

% Make list of all names occuring on RHS
namesOfRhs = regexp(rhs, '&?\?\w+', 'match');
namesOfRhs = [ namesOfRhs{:} ];
namesOfRhs = unique(namesOfRhs);

inxOfSteadyRef = strncmp(namesOfRhs, '&', 1);
namesOfSteadyRef = namesOfRhs(inxOfSteadyRef);
namesOfSteadyRef = strrep(namesOfSteadyRef, '&?', '');
namesOfRhs(inxOfSteadyRef) = [ ];
namesOfRhs = strrep(namesOfRhs, '?', '');

this.EqtnRhs = rhs;
this.NamesOfRhs = namesOfRhs;
this.NamesOfSteadyRef = namesOfSteadyRef;

nanValue = nan(1, numOfEquations);
ixEmpty = cellfun(@isempty, euc.RhsSteady);
for i = find(ixr & ~ixEmpty)
    try %#ok<TRYNC>
        x = str2num(euc.RhsSteady{i}); %#ok<ST2NM>
        if isnumericscalar(x)
            nanValue(i) = x;
        end
    end
end
this.NaN = nanValue(ixr);

end%

