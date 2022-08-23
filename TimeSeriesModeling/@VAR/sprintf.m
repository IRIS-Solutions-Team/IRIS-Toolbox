% sprintf  Print VAR model as f + 1;ormatted model code
%{
% __Syntax__
%
%     [c, d] = sprintf(v, ...)
%
%
% __Input Arguments__
%
% * `v` [ VAR ] - VAR object that will be printed as a formatted model code.
%
%
% __Output Arguments__
%
% * `c` [ cellstr ] - Text string with the model code for each
% parameterisation.
%
% * `d` [ cell ] - Parameter database for each parameterisation; if
% `'HardParameters='` is true, the databases will be empty.
%
%
% __Options__
%
% * `'Decimal='` [ numeric | *empty* ] - Precision (number of decimals) at
% which the coefficients will be written if `'HardParameters='` is true; if
% empty, the `'Format='` options is used.
%
% * `'Declare='` [ `true` | *`false`* ] - Add declaration blocks and
% keywords for VAR variables, shocks, and equations.
%
% * `'ResidualNames='` [ cellstr | char | *empty* ] - Names that will be given to
% the VAR residuals; if empty, the names from the VAR object will be used.
%
% * `'Format='` [ char | *'%+.16g'* ] - Numeric format for parameter values;
% it will be used only if `'Decimal='` is empty.
%
% * `'HardParameters='` [ *`true`* | `false` ] - Print coefficients as hard
% numbers; otherwise, create parameter names and return a parameter
% database.
%
% * `'EndogenousNames='` [ cellstr | char | *empty* ] - Names that will be given to
% the variables; if empty, the names from the VAR object will be used.
%
% * `'Tolerance='` [ numeric | *getrealsmall( )* ] - Treat VAR coefficients
% smaller than `'Tolerance='` in absolute value as zeros; zero coefficients
% will be dropped from the model code.
%
%
% __Description__
%
%
% __Example__
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function [code, d] = sprintf(this, varargin)

%( Input pp
persistent pp
if isempty(pp)
    pp = extend.InputParser('@VAR/sprintf');
    pp.addRequired(  'VAR', @(x) isa(x, 'VAR'));
    pp.addParameter({'Constant', 'Constants', 'Const'}, true, @validate.logicalScalar);
    pp.addParameter({'Decimal', 'Decimals'}, [ ], @(x) isempty(x) || validate.numericScalar(x));
    pp.addParameter( 'Declare', false, @validate.logicalScalar);
    pp.addParameter({'ResidualNames', 'ENames', 'EName'}, string.empty(1, 0), @validate.list);
    pp.addParameter( 'Format', '%+.16g', @(x) validate.stringScalar(x) && contains(x, "%+"));
    pp.addParameter({'HardParameters', 'HardParameter'}, true, @validate.logicalScalar);
    pp.addParameter( 'Tolerance', @auto, @(x) isa(x, @auto) || validate.numericScalar(x));
    pp.addParameter({'EndogenousNames', 'YNames', 'YName'}, string.empty(1, 0), @validate.list);
    pp.addParameter("ExogenousNames", string.empty(1, 0), @validate.list);
end
%)
opt = parse(pp, this, varargin{:});

if ~isempty(opt.Decimal)
    opt.Format = "%+." + string(round(opt.Decimal)) + "f";
end
opt.Format = string(opt.Format);

if isequal(opt.Tolerance, @auto)
    opt.Tolerance = this.Tolerance.Solve;
end

%--------------------------------------------------------------------------

ny = this.NumEndogenous;
p = size(this.A, 2) / max(ny, 1);
nv = size(this.A, 3);

endogenousNames = locallyResolveNames("EndogenousNames", this, opt);
residualNames = locallyResolveNames("ResidualNames", this, opt);
exogenousNames = locallyResolveNames("ExogenousNames", this, opt);

% Create string array [ "y1", "y1{-1}", ...; "y2", "y2{-1}", ...; ... ]
endogenousNamesWithShift = endogenousNames;
inxNeedsShift = ~contains(endogenousNamesWithShift, "{t}");
endogenousNamesWithShift(inxNeedsShift) = endogenousNamesWithShift(inxNeedsShift) + "{t}";
endogenousNamesWithShift = replace(endogenousNamesWithShift, "{t}", "{%+g}");
endogenousNamesWithShift = reshape(endogenousNamesWithShift, [ ], 1);
endogenousNamesWithShift = [reshape(endogenousNames, [ ], 1), repmat(endogenousNamesWithShift, 1, p)];
for i = 1 : ny
    for j = 1 : p
        endogenousNamesWithShift(i, j+1) = sprintf(endogenousNamesWithShift(i, j+1), -j);
    end
end

% Number of digits for printing parameter indices
if ~opt.HardParameters
    numDecimals = 1 + floor(log10(max(ny, p)));
    parameterFormat = "%" + string(numDecimals) + "g";
end

% Preallocatte output arguments
code = repmat("", 1, nv);
d = cell(1, nv);

for v = 1 : nv
    % Reset the list of parameters for each parameterisation
    parameterNames = string.empty(1, 0);
    
    % Retrieve VAR system matrices.
    A = reshape(this.A(:, :, v), [ny, ny, p]);
    K = this.K(:, v);
    if ~opt.Constant
        K(:) = 0;
    end
    [c, B] = getResidualComponents(this, v);
	R = covfun.cov2corr(c);
    
    % Print individual equations
    equations = repmat("", 1, ny);
    d{v} = struct( );
    
    for eq = 1 : ny
        % LHS with current-dated endogenous variable
        equations(eq) = endogenousNamesWithShift(eq, 1) + " =";
        rhs = false;
        if abs(K(eq))>opt.Tolerance || ~opt.HardParameters
            equations(eq) = equations(eq) + " " + herePrintParameter("K", {eq}, K(eq));
            rhs = true;
        end
        
        % Lags of endogenous variables
        for t = 1 : p
            for y = 1 : ny
                if abs(A(eq, y, t))>opt.Tolerance || ~opt.HardParameters
                    equations(eq) = equations(eq) ...
                        + " " + herePrintParameter("A", {eq, y, t}, A(eq, y, t)) ...
                        + "*" + endogenousNamesWithShift(y, 1+t);
                    rhs = true;
                end
            end
        end
        
        % Shocks
        for e = 1 : ny
            value = B(eq, e);
            if abs(value)>opt.Tolerance || ~opt.HardParameters
                equations(eq) = equations(eq) ...
                    + " " + herePrintParameter("B", {eq, e}, value) + "*" + residualNames(e);
                rhs = true;
            end
        end
        
        if ~rhs
            % If nothing occurs on the RHS, add zero
            equations(eq) = equations(eq) + " 0";
        end
    end
    
    equations = replace(equations, "+1*", "+");

    % Declare variables if requested
    if opt.Declare
        br = string(newline( ));
        lead = "    ";
        createWrappedList = @(list) join(lead + textual.wrapList(list, 75, ", "), br);
        declareEndogenous = createWrappedList(endogenousNames);
        declareResiduals = createWrappedList(residualNames);
        code(v) = ...
            "!variables" + br + declareEndogenous + br + br + ...
            "!shocks" + br + declareResiduals + br + br + ...
            "!equations" + br + sprintf("    %s;\n", equations) + br;
        if ~opt.HardParameters
            declareParameters = createWrappedList(parameterNames);
            code(v) = code(v) + "!parameters" + br + declareParameters + br;
        end
    else
        code(v) = sprintf("%s;\n", equations);
    end
    
    % Add std and corr to the parameter database
    if ~opt.HardParameters
        for i = 1 : ny
            name = model.Quantity.printStd(residualNames(i));
            d{v}.(name) = sqrt(c(i, i));
            for j = 1 : i-1
                if abs(R(i, j))>opt.Tolerance
                    name = model.Quantity.printCorr(residualNames(i), residualNames(j));
                    d{v}.(name) = R(i, j);
                end
            end
        end
    end
end

return

    function x = herePrintParameter(matrix, pos, value)
        if opt.HardParameters
            x = sprintf(opt.Format, value);
        else
            if p<=1 && numel(pos)==3
                pos = pos(1:2);
            end
            x = matrix + sprintf(parameterFormat, pos{:});
            d{v}.(x) = value;
            parameterNames(end+1) = x;
            x = "+" + x;
        end
    end%
end%

%
% Local Functions
%

function names = locallyResolveNames(kind, this, opt);
    if isempty(opt.(kind))
        names = string(this.(kind));
    else
        names = string(opt.(kind));
    end
end%




%
% Unit Tests
%
%{
% saveAs=VAR/sprintf.m
##### SOURCE BEGIN #####

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);

%% Test VARX

d.x1 = Series(1:20, @rand);
d.x2 = Series(1:20, @rand);
d.x3 = Series(1:20, @rand);
d.g1 = Series(1:20, @rand);
d.g2 = Series(1:20, @rand);

v = VAR(["x1", "x2", "x3"], "Exogenous", ["g1", "g2"]);

##### SOURCE END #####
%}
