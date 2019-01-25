function this = postparse(this, equation, euc)
% myparse  Post-parse rpteq input code.
%
% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

TYPE = @int8;

%--------------------------------------------------------------------------

ixr = equation.Type==TYPE(6);
if ~any(ixr)
    return
end
nEqtn = length(equation.Input);

ixValid = true(1, nEqtn);
for i = find(ixr)
    ixValid(i) = isvarname(euc.LhsDynamic{i});
end
if any(~ixValid)
    throw( exception.Base('RptEq:INVALID_LHS', 'error'), ...
        equation.Input{~ixValid} );
end

this.UsrEqtn = equation.Input(ixr);
this.NameLhs = euc.LhsDynamic(ixr);
this.Label = equation.Label(ixr);
this.MaxSh = max( euc.MaxShDynamic(ixr) );
this.MinSh = min( euc.MinShDynamic(ixr) );
rhs = euc.RhsDynamic(ixr);

% Add prefix `?` and suffix `(:,t)` to names (or names with curly braces)
% not followed by opening bracket or dot and not preceded by exclamation
% mark. The result is `?x#` or `?x{@-k}#`.
rhs = regexprep(rhs, ...
    '(?<!!)(\<[a-zA-Z]\w*\>(\{.*?\})?)(?![\(\.])', '?$1#');

% Vectorize *, /, \, ^ operators.
rhs = textfun.vectorize(rhs);

% Make list of all names occuring on RHS.
lsNameRhs = regexp(rhs, '&?\?\w+', 'match');
lsNameRhs = [ lsNameRhs{:} ];
lsNameRhs = unique(lsNameRhs);

ixSteadyRef = strncmp(lsNameRhs, '&', 1);
lsSteadyRef = lsNameRhs(ixSteadyRef);
lsSteadyRef = strrep(lsSteadyRef, '&?', '');
lsNameRhs(ixSteadyRef) = [ ];
lsNameRhs = strrep(lsNameRhs, '?', '');

this.EqtnRhs = rhs;
this.NameRhs = lsNameRhs;
this.NameSteadyRef = lsSteadyRef;

nanValue = nan(1, nEqtn);
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

end
