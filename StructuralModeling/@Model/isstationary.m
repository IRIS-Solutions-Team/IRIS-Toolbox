function [flag, test] = isstationary(this, varargin)

EIGEN_TOLERANCE = this.Tolerance.Eigen;

%--------------------------------------------------------------------------

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
    [flag, test] = locallyCointegrationStatus(this, varargin{1}, EIGEN_TOLERANCE);
end

end%


%
% Local Functions
%


function [flag, test] = locallyCointegrationStatus(this, expn, EIGEN_TOLERANCE)
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
end%

