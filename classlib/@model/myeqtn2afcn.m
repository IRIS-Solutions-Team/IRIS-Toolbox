 function this = myeqtn2afcn(this)
% myeqtn2afcn  Convert equation strings to anonymous functions.
%
% Backed IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

%--------------------------------------------------------------------------

ixm = this.Equation.Type==TYPE(1);
ixt = this.Equation.Type==TYPE(2);
ixd = this.Equation.Type==TYPE(3);
ixu = this.Equation.Type==TYPE(5);
ixmt = ixm | ixt;

% Extract the converted equations into local variables to speed up the
% executiona considerably. This is a Matlab issue.

% Dtrends, Revisions
%--------------------
eqtn = this.Equation.Dynamic;
for i = find(ixd)
    eqtn{i} = vectorize(eqtn{i});
end
eqtn(ixd) = convert(eqtn(ixd), this.PREAMBLE_DTREND, str2func([this.PREAMBLE_DTREND, '0']));
eqtn(ixu) = convert(eqtn(ixu), this.PREAMBLE_REVISION, [ ]);
this.Equation.Dynamic = eqtn;

% Links
%-------
for i = 1 : length(this.Link)
    this.Link.RhsExpn{i} = vectorize(this.Link.RhsExpn{i});
end
this.Link.RhsExpn = convert(this.Link.RhsExpn, this.PREAMBLE_LINK, [ ]);

% Gradients 
%-----------
% Derivatives of dynamic transition and measurement equations wrt variables
% and shocks, derivatives of dtrend equations wrt parameters.
gd = this.Gradient.Dynamic(1, :);
gs = this.Gradient.Steady(1, :);
gd(ixmt) = convert(gd(ixmt), this.PREAMBLE_DYNAMIC, [ ]);
gs(ixmt) = convert(gs(ixmt), this.PREAMBLE_STEADY, [ ]);
for i = find(ixd)
    gd{i} = convert(gd{i}, this.PREAMBLE_DTREND, [ ]);
end
this.Gradient.Dynamic(1, :) = gd;
this.Gradient.Steady(1, :) = gs;

end





function eqtn = convert(eqtn, header, ifEmpty)
FN_REMOVE_HEADER = @(x) regexprep(x, '^@\(.*?\)\s*', '', 'once');
if true % ##### MOSW
    FN_STR2FUNC = @str2func;
else
    FN_STR2FUNC = @mosw.str2func; %#ok<UNRCH>
end

for i = 1 : length(eqtn)
    if isnumeric(eqtn{i})
        continue
    end
    if isa(eqtn{i}, 'function_handle')
        eqtn{i} = func2str(eqtn{i});
    end
    if ischar(eqtn{i})
        eqtn{i} = FN_REMOVE_HEADER(eqtn{i});
    end
    if isempty(eqtn{i})
        eqtn{i} = ifEmpty;
    else
        eqtn{i} = FN_STR2FUNC([header, ' ', eqtn{i}]);
    end
end
end
