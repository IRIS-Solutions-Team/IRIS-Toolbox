function [deriv, inxNaDeriv] = diffFirstOrder(this, inxToDiff, variantRequested, opt)

isNaDeriv = nargout>2;

% Copy last computed derivatives
deriv = this.LastSystem.Deriv;

asgn = this.Variant.Values(:, :, variantRequested);
numQuantities = numel(this.Quantity);
numEquations = numel(this.Equation);
inxY = this.Quantity.Type==1;
inxX = this.Quantity.Type==2;
inxE = this.Quantity.Type==31 | this.Quantity.Type==32;
inxYXE = inxY | inxX | inxE;
inxP = this.Quantity.Type==4;
inxLog = this.Quantity.InxLog;
nsh = this.Incidence.Dynamic.NumShifts;

inxM = this.Equation.Type==1;
inxT = this.Equation.Type==2;
inxMT = inxM | inxT;
inxToDiff(~inxMT) = false;

inxNaDeriv = false(1, numEquations);

if any(inxToDiff)
    numYXE = sum(inxYXE);
    sh0 = this.Incidence.Dynamic.PosZeroShift;
    if opt.Symbolic
        inxSymbolic = ~cellfun(@isempty, this.Gradient.Dynamic(1, :));
    else
        inxSymbolic = false(1, numEquations);
    end
    inxSymbolic = inxSymbolic & inxToDiff;
    inxNumeric = ~inxSymbolic & inxToDiff;

    % Symbolic differentiation
    if any(inxSymbolic)
        deriv = here_diffSymbolically(deriv);
    end

    % Numerical differentiation 
    if any(inxNumeric)
        if this.LinearStatus
            % Linear models 
            deriv = here_diffNumericallyLinear(deriv);
        else
            % Nonlinear models
            deriv = here_diffNumericallyNonlinear(deriv);
        end
    end

    % Reset the add-factors in nonlinear equations to 1
    eyeAddf = -eye(sum(this.Equation.Type<=2));
    deriv.n(inxToDiff, :) = eyeAddf(inxToDiff, this.Equation.IxHash);

    % Normalize derivatives by largest number in nonlinear models
    if ~this.LinearStatus && opt.Normalize
        for iEq = find(inxToDiff)
            inx = deriv.f(iEq, :)~=0;
            if any(inx)
                norm = max(abs(deriv.f(iEq, inx)));
                deriv.f(iEq, inx) = deriv.f(iEq, inx) / norm;
                deriv.n(iEq, :) = deriv.n(iEq, :) / norm;
            end
        end
    end
end

return

    function deriv = here_diffNumericallyLinear(deriv)
        %(
        init = zeros(numQuantities, 1);
        init(inxP) = real(asgn(inxP));
        init = repmat(init, 1, nsh);
        xPlus = ones(numQuantities, 1);

        % Delog log-plus variables
        if any(inxLog)
            init(inxLog, :) = exp(0);
            xPlus(inxLog) = exp(1);
        end

        for iiEq = find(inxNumeric)
            % Get incidence of variables in this equation.
            nm = reshape(real(this.Gradient.Dynamic{2, iiEq}), 1, [ ]);
            sh = sh0 + reshape(imag(this.Gradient.Dynamic{2, iiEq}), 1, [ ]);

            equationFunc = this.Equation.DynamicFunc{iiEq};
            f0 = equationFunc(init, sh0, []);

            % Total number of derivatives to be computed in this equation.
            n = numel(nm);
            value = zeros(1, n);
            [numRows, numColumns] = size(init);
            for jj = 1 : n
                iNm = nm(jj);
                iSh = sh(jj);
                temp = init(iNm, iSh);
                init(iNm, iSh) = xPlus(iNm);
                fPlus = equationFunc(init, sh0, []);
                init(iNm, iSh) = temp;
                value(jj) = fPlus - f0; 
            end

            % Constant in linear models
            deriv.c(iiEq) = f0;

            % Assign values to the array of derivatives.
            inx = (sh-1)*numYXE + nm;
            deriv.f(iiEq, inx) = value;

            % Check for NaN derivatives.
            if isNaDeriv && any(~isfinite(value))
                inxNaDeriv(iiEq) = true;
            end
        end
        %)
    end%


    function deriv = here_diffNumericallyNonlinear(deriv)
        %(
        minT = 1 - sh0;
        maxT = nsh - sh0;
        tVec = minT : maxT;

        isDelog = false;
        init = createTrendArray(this, variantRequested, isDelog, 1:numQuantities, tVec);
        diffStep = this.Tolerance.DiffStep;
        maxInitOrOne = init;
        maxInitOrOne(init<1) = 1;
        h = diffStep * maxInitOrOne;
        xPlus = init + h;
        xMinus = init - h;

        %
        % Keep track of the actual step (this can be numerically slightly
        % different from `h`)
        %
        % Any imag parts in `xPlus` and `xMinus` should cancel; `real( )` does no
        % harm here_ therefore
        %
        step = real(xPlus) - real(xMinus);

        % Delog log-plus variables.
        if any(inxLog)
            init(inxLog, :) = real(exp( init(inxLog,:) ));
            xPlus(inxLog, :) = real(exp( xPlus(inxLog,:) ));
            xMinus(inxLog, :) = real(exp( xMinus(inxLog,:) ));
        end

        % References to steady levels; can be used only in nonlinear setup
        L = init;

        for iiEq = find(inxNumeric)
            % Get incidence of variables in this equation
            nm = reshape(real(this.Gradient.Dynamic{2, iiEq}), 1, [ ]);
            sh = sh0 + reshape(imag(this.Gradient.Dynamic{2, iiEq}), 1, [ ]);

            equationFunc = this.Equation.DynamicFunc{iiEq};

            % Total number of derivatives to be computed in this equation
            numDiff = numel(nm);

            value = zeros(1, numDiff);
            for jj = 1 : numDiff
                iNm = nm(jj);
                iSh = sh(jj);

                % Reusing init is much faster than creating a new array for
                % plus and minus
                temp = init(iNm, iSh);
                init(iNm, iSh) = xMinus(iNm, iSh);
                fMinus = equationFunc(init, sh0, L);
                init(iNm, iSh) = temp;

                temp = init(iNm, iSh);
                init(iNm, iSh) = xPlus(iNm, iSh);
                fPlus =  equationFunc(init, sh0, L);
                init(iNm, iSh) = temp;

                value(jj) = (fPlus-fMinus) / step(nm(jj), sh(jj));
            end

            % Assign values to the array of derivatives
            inx = (sh-1)*numYXE + nm;
            deriv.f(iiEq, inx) = value;

            % Check for Na derivatives
            if isNaDeriv && any( ~isfinite(value) )
                inxNaDeriv(iiEq) = true;
            end
        end
        %)
    end%


    function deriv = here_diffSymbolically(deriv)
        %(
        if this.LinearStatus
            x = zeros(numQuantities, 1);
            x(inxLog) = 1;
            x(inxP) = real(asgn(inxP));
            x = repmat(x, 1, nsh);
            % References to steady-state levels.
            L = [ ];
        else
            isDelog = true;
            x = createTrendArray(this, variantRequested, isDelog);
            % References to steady-state levels
            L = x;
        end

        for iiEq = find(inxSymbolic)
            % Get incidence of variables in this equation
            nm = reshape(real(this.Gradient.Dynamic{2, iiEq}), 1, [ ]);
            sh = sh0 + reshape(imag(this.Gradient.Dynamic{2, iiEq}), 1, [ ]);

            % Log derivatives need to be multiplied by x 
            %
            % Log-plus and log-minus variables are treated the same way
            % because
            %
            % df(x)/dlog(xm) = df(x)/d(x) * d(x)/d(xm) * d(xm)/dlog(xm)
            %                = df(x)/d(x) * (-1) * xm = df(x)/d(x) * (-1) * (-1)*x
            %                = df(x)/d(x) * x
            logMultipliers = [];
            if any(inxLog(nm))
                logMultipliers = ones(size(nm));
                for ii = find( inxLog(nm) )
                    logMultipliers(ii) = x(nm(ii), sh(ii));
                end
            end

            % Evaluate all derivatives at once
            value = this.Gradient.Dynamic{1, iiEq}(x, sh0, L);
            value = reshape(value, 1, [ ]);

            % Multiply derivatives wrt to log variables by x
            if ~isempty(logMultipliers)
                value = value .* logMultipliers;
            end

            % Assign values to the array of derivatives
            inx = (sh-1)*numYXE + nm;
            deriv.f(iiEq, inx) = value;

            % Check for NaN derivatives
            if isNaDeriv && any( ~isfinite(value) )
                inxNaDeriv(iiEq) = true;
            end
        end

        % Evaluate all equations at x=0, log(x)=0 to get constant terms
        if this.LinearStatus
            equationFunc = str2func([this.Equation.PREAMBLE, '[', this.Equation.Dynamic{inxSymbolic}, ']', ]);
            deriv.c(inxSymbolic) = equationFunc(x, sh0, L);
        end
        %)
    end%
end%

