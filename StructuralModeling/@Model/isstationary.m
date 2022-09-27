%{
% 
% # `isStationary` ^^(Model)^^
% 
% {== True if the model or a linear combination of its variables is stationary ==}
% 
% 
% ## Syntax
% 
%      flag = isStationary(m)
%      flag = isStationary(m, name)
%      flag = isStationary(m, expression)
% 
% 
% ## Input arguments 
% 
% __`m`__ [ model ]
% > 
% > Model object.
% > 
% 
% __`name`__ [ string ]
% > 
% > Transition variable name.
% > 
% 
% __`expression`__ [ string ] 
% > 
% > Text string defining a linear combination of
% > transition variables; log variables need to be enclosed in `log(...)`.
% > 
% 
% ## Output arguments 
% 
% __`flag`__ [ `true` | `false` ]
% > 
% > True if the model (if called without a
% > second input argument) or the specified transition variable or
% > combination of transition variables (if called with a second input
% > argument) is stationary.
% > 
% 
% ## Description
% 
% 
% ## Examples
% 
% In the following examples, `m` is a solved model object with two of its
% transition variables named `x` and `y`, with the latter being declared as
% a log variable:
% 
% ```matlab
%     isStationary(m)
%     isStationary(m, 'x')
%     isStationary(m, 'log(y)')
%     isStationary(m, 'x - 0.5*log(y)')
% ```
% 
% 
%}
% --8<--


function [flag, test] = isstationary(this, varargin)

    EIGEN_TOLERANCE = this.Tolerance.Eigen;

    if isempty(this.Variant.FirstOrderSolution{1})
        flag = NaN;
        return
    end

    if isempty(varargin)
        %
        % Called:
        % flag = isstationary(this)
        %
        flag = all(this.Variant.EigenStability~=1, 2);
        flag = permute(flag, [1, 3, 2]);
    else
        %
        % Called:
        % [flag, test] = isstationary(this, expn)
        %
        [flag, test] = local_cointegrationStatus(this, varargin{1}, EIGEN_TOLERANCE);
    end

end%


function [flag, test] = local_cointegrationStatus(this, expn, EIGEN_TOLERANCE)
    %(
    [~, ~, ~, nf] = sizeSolution(this.Vector);
    nv = countVariants(this);
    % Get the vector of coefficients describing the tested linear combination.
    % Normalize the vector of coefficients by the largest coefficient.
    [w, ~, isValid] = parser.vectorizeLinComb(expn, printSolutionVector(this, 'x'));
    assert( ...
        isValid && any(w~=0), ...
        'model:isstationary', ...
        'This is not a valid linear combination of transition variables: %s ', ...
        expn ...
    );
    w = w / max(w);
    % Test stationarity of the linear combination in each parameter variant.
    flag = false(1, nv);
    test = cell(1, nv);
    numUnitRoots = getNumOfUnitRoots(this.Variant);
    for v = 1 : nv
        [T, ~, ~, ~, ~, ~, U] = getSolutionMatrices(this, v);
        test{v} = w*[ T(1:nf, 1:numUnitRoots(v)); U(:, 1:numUnitRoots(v)) ];
        flag(v) = all( abs(test{v})<=EIGEN_TOLERANCE );
    end
    %)
end%

