function [A, B, C, D, F, G, H, J, list, nf, deriv] = system(this, varargin)
% system  System matrices for unsolved model.
%
% Syntax
% =======
%
%     [A,B,C,D,F,G,H,J,List,Nf] = system(M)
%
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object whose system matrices will be returned.
%
%
% Output arguments
% =================
%
% * `A`, `B`, `C`, `D`, `F`, `G`, `H` ,`J`  [ numeric ] - Matrices
% describing the unsolved system, see Description.
%
% * `List` [ cell ] - Lists of measurement variables, transition variables
% includint their auxiliary lags and leads, and shocks as they appear in
% the rows and columns of the system matrices.
%
% * `Nf` [ numeric ] - Number of non-predetermined (forward-looking)
% transition variables (multiplied by the first `Nf` columns of matrices
% `A` and `B`).
%
%
% Options
% ========
%
% * `'Select='` [ *`true`* | `false` ] - Automatically detect which
% equations need to be re-differentiated based on parameter changes from
% the last time the system matrices were calculated.
%
% * `'Sparse='` [ `true` | *`false`* ] - Return matrices `A`, `B`, `D`,
% `F`, `G`, and `J` as sparse matrices; can be set to `true` only in models
% with one parameterization.
%
%
% Description
% ============
%
% The system before the model is solved has the following form:
%
%     A E[xf;xb] + B [xf(-1);xb(-1)] + C + D e = 0
%
%     F y + G xb + H + J e = 0
%
% where `E` is a conditional expectations operator, `xf` is a vector of
% non-predetermined (forward-looking) transition variables, `xb` is a
% vector of predetermined (backward-looking) transition variables, `y` is a
% vector of measurement variables, and `e` is a vector of transition and
% measurement shocks.
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

opt = passvalopt('model.system', varargin{:});

%--------------------------------------------------------------------------

nAlt = length(this);

if opt.sparse && nAlt>1
    utils.warning('model:system', ...
        ['Cannot return system matrices as sparse matrices in models ', ...
        'with multiple parameterizations. Returning full matrices instead.']);
    opt.sparse = false;
end

% System matrices.
if opt.sparse && nAlt==1
    [syst, ~, deriv] = systemFirstOrder(this, 1, opt);
    F = syst.A{1}; %#ok<*AGROW>
    G = syst.B{1};
    H = syst.K{1};
    J = syst.E{1};
    A = syst.A{2};
    B = syst.B{2};
    C = syst.K{2};
    D = syst.E{2};
else
    for iAlt = 1 : nAlt
        [syst, ~, deriv] = systemFirstOrder(this, iAlt, opt);
        F(:, :, iAlt) = full(syst.A{1}); %#ok<*AGROW>
        G(:, :, iAlt) = full(syst.B{1});
        H(:, 1, iAlt) = full(syst.K{1});
        J(:, :, iAlt) = full(syst.E{1});
        A(:, :, iAlt) = full(syst.A{2});
        B(:, :, iAlt) = full(syst.B{2});
        C(:, 1, iAlt) = full(syst.K{2});
        D(:, :, iAlt) = full(syst.E{2});
    end
end

% Lists of measurement variables, backward-looking transition variables, and
% forward-looking transition variables.
list = { ...
    printSolutionVector(this, 'y'), ...
    printSolutionVector(this, this.Vector.System{2} + 1i), ...
    printSolutionVector(this, 'e'), ...
    };

% Number of forward-looking variables.
nf = sum( imag(this.Vector.System{2})>=0 );

end
