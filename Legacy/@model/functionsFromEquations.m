function this = functionFromEquations(this)

inxM = this.Equation.Type==1;
inxT = this.Equation.Type==2;
inxL = this.Equation.Type==4;
inxD = this.Equation.Type==3;
inxMTL = inxM | inxT | inxL;
preamble = this.Equation.PREAMBLE;

% Extract the converted equations into local variables to speed up the
% execution considerably. This is a Matlab issue.

%
% Measurement trend equations
%
eqtn = this.Equation.Dynamic;
for i = find(inxD)
    eqtn{i} = vectorize(eqtn{i});
end
eqtn(inxD) = convert(eqtn(inxD), preamble, str2func([preamble, '0']));
this.Equation.Dynamic = eqtn;


%
% RHs expressions in links
%
for i = 1 : numel(this.Link)
    this.Link.RhsExpn{i} = vectorize(this.Link.RhsExpn{i});
end
this.Link.RhsExpn = convert(this.Link.RhsExpn, preamble, [ ]);


%
% Gradients 
%

% Derivatives of dynamic transition and measurement equations and dynamic
% links wrt variables and shocks; derivatives of dtrend equations wrt
% parameters
gd = this.Gradient.Dynamic(1, :);
gs = this.Gradient.Steady(1, :);
gd(inxMTL) = convert(gd(inxMTL), preamble, [ ]);
gs(inxMTL) = convert(gs(inxMTL), preamble, [ ]);
for i = find(inxD)
    gd{i} = convert(gd{i}, preamble, [ ]);
end
this.Gradient.Dynamic(1, :) = gd;
this.Gradient.Steady(1, :) = gs;

end%


%
% Local Functions
%


function eqtn = convert(eqtn, header, whenEmpty)
    REMOVE_HEADER = @(x) regexprep(x, '^@\(.*?\)\s*', '', 'once');
    FN_STR2FUNC = @str2func;

    for i = 1 : numel(eqtn)
        if isnumeric(eqtn{i})
            continue
        end
        if isa(eqtn{i}, 'function_handle')
            eqtn{i} = func2str(eqtn{i});
        end
        if ischar(eqtn{i})
            eqtn{i} = REMOVE_HEADER(eqtn{i});
        end
        if isempty(eqtn{i})
            eqtn{i} = whenEmpty;
        else
            eqtn{i} = FN_STR2FUNC([header, ' ', eqtn{i}]);
        end
    end
end%

