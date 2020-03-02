function [flag, test] = isstationary(this, varargin)
% isstationary  True if model or specified combination of variables is stationary.
%
% ## Syntax ##
%
%     Flag = isstationary(M)
%     Flag = isstationary(M, Name)
%     Flag = isstationary(M, LinComb)
%
%
% ## Input Arguments ##
%
% * `M` [ model ] - Model object.
%
% * `Name` [ char ] - Transition variable name.
%
% * `LinComb` [ char ] - Text string defining a linear combination of
% transition variables; log variables need to be enclosed in `log(...)`.
%
%
% ## Output Arguments ##
%
% * `Flag` [ `true` | `false` ] - True if the model (if called without a
% second input argument) or the specified transition variable or
% combination of transition variables (if called with a second input
% argument) is stationary.
%
%
% ## Description ##
%
%
% ## Example ##
%
% In the following examples, `m` is a solved model object with two of its
% transition variables named `X` and `Y`; the latter is a log variable:
%
%     isstationary(m)
%     isstationary(m, 'X')
%     isstationary(m, 'log(Y)')
%     isstationary(m, 'X - 0.5*log(Y)')
%

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

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
    TYPE = @int8;
    flag = all(this.Variant.EigenStability~=TYPE(1), 2);
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
    [~, ~, ~, nf] = sizeOfSolution(this.Vector);
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
        [T, ~, ~, ~, ~, ~, U] = sspaceMatrices(this, v);
        test{v} = w*[ T(1:nf, 1:numUnitRoots(v)); U(:, 1:numUnitRoots(v)) ];
        flag(v) = all( abs(test{v})<=EIGEN_TOLERANCE );
    end
end%

