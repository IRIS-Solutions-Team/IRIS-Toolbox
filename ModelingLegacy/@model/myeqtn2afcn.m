 function this = myeqtn2afcn(this)
% myeqtn2afcn  Convert equation strings to anonymous functions
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

TYPE = @int8;

%--------------------------------------------------------------------------

inxM = this.Equation.Type==TYPE(1);
inxT = this.Equation.Type==TYPE(2);
inxL = this.Equation.Type==TYPE(4);
inxD = this.Equation.Type==TYPE(3);
inxMTL = inxM | inxT | inxL;

% Extract the converted equations into local variables to speed up the
% executiona considerably. This is a Matlab issue.

%
% Dtrend Equations
%
eqtn = this.Equation.Dynamic;
for i = find(inxD)
    eqtn{i} = vectorize(eqtn{i});
end
eqtn(inxD) = convert(eqtn(inxD), this.PREAMBLE_DTREND, str2func([this.PREAMBLE_DTREND, '0']));
this.Equation.Dynamic = eqtn;


%
% RHS Expressions in Links
%
for i = 1 : numel(this.Link)
    this.Link.RhsExpn{i} = vectorize(this.Link.RhsExpn{i});
end
this.Link.RhsExpn = convert(this.Link.RhsExpn, this.PREAMBLE_LINK, [ ]);


%
% Gradients 
%

% Derivatives of dynamic transition and measurement equations and dynamic
% links wrt variables and shocks; derivatives of dtrend equations wrt
% parameters
gd = this.Gradient.Dynamic(1, :);
gs = this.Gradient.Steady(1, :);
gd(inxMTL) = convert(gd(inxMTL), this.PREAMBLE_DYNAMIC, [ ]);
gs(inxMTL) = convert(gs(inxMTL), this.PREAMBLE_STEADY, [ ]);
for i = find(inxD)
    gd{i} = convert(gd{i}, this.PREAMBLE_DTREND, [ ]);
end
this.Gradient.Dynamic(1, :) = gd;
this.Gradient.Steady(1, :) = gs;

end%


%
% Local Functions
%


function eqtn = convert(eqtn, header, ifEmpty)
    REMOVE_HEADER = @(x) regexprep(x, '^@\(.*?\)\s*', '', 'once');
    if true % ##### MOSW
        FN_STR2FUNC = @str2func;
    else
        FN_STR2FUNC = @mosw.str2func; %#ok<UNRCH>
    end

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
            eqtn{i} = ifEmpty;
        else
            eqtn{i} = FN_STR2FUNC([header, ' ', eqtn{i}]);
        end
    end
end%

