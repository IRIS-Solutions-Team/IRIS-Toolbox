function [flag, test] = isstationary(this, varargin)
% isstationary  True if model or specified combination of variables is stationary.
%
%
% Syntax
% =======
%
%     Flag = isstationary(M)
%     Flag = isstationary(M,Name)
%     Flag = isstationary(M,LinComb)
%
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object.
%
% * `Name` [ char ] - Transition variable name.
%
% * `LinComb` [ char ] - Text string defining a linear combination of
% transition variables; log variables need to be enclosed in `log(...)`.
%
%
% Output arguments
% =================
%
% * `Flag` [ `true` | `false` ] - True if the model (if called without a
% second input argument) or the specified transition variable or
% combination of transition variables (if called with a second input
% argument) is stationary.
%
%
% Description
% ============
%
%
% Example
% ========
%
% In the following examples, `m` is a solved model object with two of its
% transition variables named `X` and `Y`; the latter is a log variable:
%
%     isstationary(m)
%     isstationary(m,'X')
%     isstationary(m,'log(Y)')
%     isstationary(m,'X - 0.5*log(Y)')
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

EIGEN_TOLERANCE = this.Tolerance.Eigen;

%--------------------------------------------------------------------------

if isempty(this.solution{1})
    flag = NaN;
    return
end

if isempty(varargin)
    % Called Flag = isstationary(This).
    nb = size(this.solution{1}, 2);
    eig_ = model.Variant.get(this.Variant, 'Eigen', ':');
    test = abs( eig_(1, 1:nb, :) );
    flag = all( test<1-EIGEN_TOLERANCE, 2);
    flag = permute(flag, [1, 3, 2]);
else
    % Called [Flag, Test] = isstationary(this, expn).
    [flag, test] = isCointegrated(this, varargin{1}, EIGEN_TOLERANCE);
end

end




function [flag, test] = isCointegrated(this, expn, EIGEN_TOLERANCE)
[~, ~, ~, nf] = sizeOfSolution(this.Vector);
nAlt = length(this);
% Get the vector of coefficients describing the tested linear combination.
% Normalize the vector of coefficients by the largest coefficient.
[w, ~, isValid] = parser.vectorizeLinComb(expn, printSolutionVector(this, 'x'));
if ~isValid || all(w==0)
    utils.error('model:isstationary', ...
        ['This is not a valid linear combination of ', ...
        'transition variables: %s '], ...
        expn);
end
w = w / max(w);
% Test stationarity in each parameterization.
flag = false(1, nAlt);
test = cell(1, nAlt);
for iAlt = 1 : nAlt
    Tf = this.solution{1}(1:nf, :, iAlt);
    U = this.solution{7}(:, :, iAlt);
    nUnit = sum(this.Variant{iAlt}.Stability==TYPE(1));
    test{iAlt} = w*[ Tf(:, 1:nUnit); U(:, 1:nUnit) ];
    flag(iAlt) = all( abs(test{iAlt})<=EIGEN_TOLERANCE );
end
end
