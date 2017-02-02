function [deriv, ixNanDeriv] = diffFirstOrder(this, eqSelect, iAlt, opt)
% diffFirstOrder  Calculate first-order derivatives of equations.
%
% Backed IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

isNanDeriv = nargout > 2;

if isequal(opt.linear, @auto)
    opt.linear = this.IsLinear;
end

%--------------------------------------------------------------------------

% Copy last computed derivatives.
deriv = this.LastSystem.Deriv;

asgn = this.Variant{iAlt}.Quantity;
nName = length(this.Quantity);
nEqtn = length(this.Equation);
ixy = this.Quantity.Type==TYPE(1);
ixx = this.Quantity.Type==TYPE(2);
ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
ixyxe = ixy | ixx | ixe;
ixp = this.Quantity.Type==TYPE(4);
ixm = this.Equation.Type==TYPE(1);
ixt = this.Equation.Type==TYPE(2);
ixLog = this.Quantity.IxLog;
eqSelect(~ixm & ~ixt) = false;

ixNanDeriv = false(1, nEqtn);

% Prepare 3D occur array limited to occurences of variables and shocks in
% measurement and transition equations.
nsh = nofShift(this.Incidence.Dynamic);

if any(eqSelect)    
    nyxe = sum(ixyxe);
    t0 = zero(this.Incidence.Dynamic);
    if opt.symbolic
        ixSymb = ~cellfun(@isempty, this.Gradient.Dynamic(1, :));
    else
        ixSymb = false(1, nEqtn);
    end
    ixSymb = ixSymb & eqSelect;
    ixNum = ~ixSymb & eqSelect;
    
    if any(ixSymb)
        % Symbolic derivatives.
        calcSymbDeriv( );
    end
    if any(ixNum)
        % Numerical derivatives.
        calcNumDeriv( );
    end
    
    % Reset the add-factors in non-linear equations to 1.
    tempEye = -eye(sum(this.Equation.Type<=2));
    deriv.n(eqSelect, :) = tempEye(eqSelect, this.Equation.IxHash);
    
    % Normalise derivatives by largest number in nonlinear models.
    if ~opt.linear && opt.normalize
        for iEq = find(eqSelect)
            ix = deriv.f(iEq, :)~=0;
            if any(ix)
                norm = max(abs(deriv.f(iEq, ix)));
                deriv.f(iEq, ix) = deriv.f(iEq, ix) / norm;
                deriv.n(iEq, :) = deriv.n(iEq, :) / norm;
            end
        end
    end
end

return



    function calcNumDeriv( )
        minT = 1 - t0;
        maxT = nsh - t0;
        tVec = minT : maxT;
        
        if opt.linear
            init = zeros(nName, 1);
            init(ixp) = real(asgn(ixp));
            init = repmat(init, 1, nsh);
            h = ones(size(init));
        else
            isDelog = false;
            init = createTrendArray(this, iAlt, isDelog, 1:nName, tVec);
            diffStep = this.Tolerance.DiffStep;
            maxInitOr1 = init;
            maxInitOr1(init<1) = 1;
            h = diffStep*maxInitOr1;
        end
        
        xPlus = init + h;
        xMinus = init - h;
        % Any imag parts in `xPlus` and `xMinus` should cancel; `real( )` does no
        % harm here therefore.
        step = real(xPlus - xMinus);
        
        % Delog log-plus variables.
        if any(ixLog)
            init(ixLog, :) = real(exp( init(ixLog,:) ));
            xPlus(ixLog, :) = real(exp( xPlus(ixLog,:) ));
            xMinus(ixLog, :) = real(exp( xMinus(ixLog,:) ));
        end
        
        % References to steady levels; can be used only in nonlinear setup.
        if opt.linear
            L = [ ];
        else
            L = init;
        end
        
        for iiEq = find(ixNum)
            eqtn = vectorize( this.Equation.Dynamic{iiEq} );
            fn = str2func([this.PREAMBLE_DYNAMIC, '[', eqtn, ']']);
            
            % Get incidence of variables in this equation.
            nm = real(this.Gradient.Dynamic{2, iiEq});
            sh = t0 + imag(this.Gradient.Dynamic{2, iiEq});

            % Total number of derivatives to be computed in this equation.
            n = length(nm);
            value = zeros(1, n);
            for ii = 1 : n
                iNm = nm(ii);
                iSh = sh(ii);
                gridMinus = init;
                gridPlus = init;
                gridMinus(iNm, iSh) = xMinus(iNm, iSh);
                gridPlus(iNm, iSh) = xPlus(iNm, iSh);
                fMinus = fn(gridMinus, t0, L);
                fPlus =  fn(gridPlus, t0, L);
                value(ii) = (fPlus-fMinus) / step(nm(ii), sh(ii));
            end
            
            % Constant in linear models.
            if opt.linear
                deriv.c(iiEq) = fn(init, t0, L);
            end
            
            % Assign values to the array of derivatives.
            ix = (sh-1)*nyxe + nm;
            deriv.f(iiEq, ix) = value;
            
            % Check for NaN derivatives.
            if isNanDeriv && any( ~isfinite(value) )
                ixNanDeriv(iiEq) = true;
            end
        end
    end

    
    
    function calcSymbDeriv( )
        if opt.linear
            x = zeros(nName, 1);
            x(ixLog) = 1;
            x(ixp) = real(asgn(ixp));
            x = repmat(x, 1, nsh);
            % References to steady-state levels.
            L = [ ];
        else
            isDelog = true;
            x = createTrendArray(this, iAlt, isDelog);
            % References to steady-state levels.
            L = x;
        end
   
        for iiEq = find(ixSymb)
            % Get incidence of variables in this equation.
            nm = real(this.Gradient.Dynamic{2, iiEq});
            sh = t0 + imag(this.Gradient.Dynamic{2, iiEq});

            % Log derivatives need to be multiplied by x. Log-plus and
            % log-minus variables are treated the same way because
            % df(x)/dlog(xm) = df(x)/d(x) * d(x)/d(xm) * d(xm)/dlog(xm) 
            % = df(x)/d(x) * (-1) * xm = df(x)/d(x) * (-1) * (-1)*x
            % = df(x)/d(x) *x.
            logMult = [ ];
            if any(ixLog(nm))
                logMult = ones(size(nm));
                for ii = find( ixLog(nm) )
                    logMult(ii) = x(nm(ii), sh(ii));
                end
            end
            
            % Evaluate all derivatives at once.
            value = this.Gradient.Dynamic{1, iiEq}(x, t0, L);
            
            % Multiply derivatives wrt to log variables by x.
            if ~isempty(logMult)
                value = value .* logMult;
            end

            % Assign values to the array of derivatives.
            ix = (sh-1)*nyxe + nm;
            deriv.f(iiEq, ix) = value;
            
            % Check for NaN derivatives.
            if isNanDeriv && any( ~isfinite(value) )
                ixNanDeriv(iiEq) = true;
            end
        end
        
        % Evaluate all equations at x=0, log(x)=0 to get constant terms.
        if opt.linear
            fn = str2func([this.PREAMBLE_DYNAMIC, '[', this.Equation.Dynamic{ixSymb}, ']', ]);
            deriv.c(ixSymb) = fn(x, t0, L);
        end
    end
end
