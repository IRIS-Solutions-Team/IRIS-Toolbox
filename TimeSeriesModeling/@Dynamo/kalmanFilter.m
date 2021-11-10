% Type `web Model/kalmanFilter.md` for help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

function [outputDb, this, info] = kalmanFilter(this, inputDb, range, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser('Dynamo/kalmanFilter');
    pp.addRequired('a', @(x) isa(x, 'Dynamo'));
    pp.addRequired('InputData', @validate.databank);
    pp.addRequired('Range', @isnumeric);
    pp.addParameter('Cross', true, ...
        @(x) isequal(x, true) || isequal(x, false) || (isnumeric(x) && isscalar(x) && x>=0 && x<=1));
    pp.addParameter('InvFunc', @auto, @(x) isa(x, 'function_handle'));
    pp.addParameter('MeanOnly', false, @(x) isequal(x, true) || isequal(x, false));
    pp.addParameter('Persist', false, @(x) isequal(x, true) || isequal(x, false));
    pp.addParameter('Tolerance', 0, @(x) isnumeric(x) && isscalar(x));
end
opt = pp.parse(this, inputDb, range, varargin{:});

numY = size(this.C, 1);
numF = size(this.C, 2);
order = size(this.A, 2) / numF;

info = struct();

%
% Retrieve and standardize input data
%
range = double(range);
y = hereGetObserved();
[this, y] = stdize(this, y);
numPeriods = size(y, 2);


%
% Initialise Kalman filter
%
x0 = zeros(order*numF, 1);
R = transpose(this.U(1:numF, :)) * this.B;
inumFUnitRoots = this.EigenStability==1;
P0 = covfun.acovf(this.T, R, [ ], [ ], [ ], [ ], this.U, 1, inumFUnitRoots, 0);


Sgm = this.Sigma;
% Reduce or zero off-diagonal elements in the cov matrix of idiosyncratic
% residuals if requested.
opt.Cross = double(opt.Cross);
if opt.Cross<1
    inumFDiag = logical(eye(size(Sgm)));
    Sgm(~inumFDiag) = opt.Cross * Sgm(~inumFDiag);
end

% Inversion method for the FMSE matrix. It is safe to use `inv` if
% cross-correlations are pulled down because then the idiosyncratic cov
% matrix is non-singular.
if isequal(opt.InvFunc, @auto)
    if this.Cross==1 && opt.Cross==1
        invFunc = @pinv;
    else
        invFunc = @inv;
    end
else
    invFunc = opt.InvFunc;
end

% __Run VAR Kalman Smoother__
% Run Kalman smoother to re-estimate the common factors taking the
% coefficient matrices as given. If `allobserved` is true then the VAR
% smoother makes an assumption that the factors are uniquely determined
% whenever all observables are available; this is only true if the
% idiosyncratic covariance matrix is not scaled down.
s = struct( );
s.invFunc = invFunc;
s.allObs = this.Cross==1 && opt.Cross==1;
s.tol = opt.Tolerance;
s.reuse = opt.Persist;
s.ahead = 1;

[x, Px, ee, uu, y, Py] ...
    = shared.Kalman.smootherForVAR(this, this.A, this.B, [], this.C, [], 1, Sgm, y, [], x0, P0, s);

if opt.MeanOnly
    Px = Px(:, :, [], []);
    Py = [];
end


%
% Observed
%
[y, Py] = Dynamo.destdize(y, this.Mean, this.Std, Py);

%
% Common components
%
[cc, Pc] = Dynamo.cc(this.C, x(1:numF, :, :), Px(1:numF, 1:numF, :, :));
[cc, Pc] = Dynamo.destdize(cc, this.Mean, this.Std, Pc);


%
% Factors
%
f = x(1:numF, :, :);
Pf = Px(1:numF, 1:numF, :, :);


%
% Idiosyncratic residuals
%
uu = Dynamo.destdize(uu, 0, this.Std);


if ~opt.MeanOnly
    Sy = covfun.cov2stdcorr(Py, true);
    Sc = covfun.cov2stdcorr(Pc, true);
    Sf = covfun.cov2stdcorr(Pf, true);
end


%
% Create output databank
%
outputDb = hereCreateOutputDb();


return

    function inputArray = hereGetObserved()
        %(
        numBasePeriods = round(range(end) - range(1) + 1);
        if ~isempty(inputDb)
            requiredNames = string.empty(1, 0);
            optionalNames = this.ObservedNames;
            allowedNumeric = @all;
            logNames = string.empty(1, 0);
            context = "";
            dbInfo = checkInputDatabank( ...
                this, inputDb, range ...
                , requiredNames, optionalNames ...
                , allowedNumeric, logNames ...
                , context ...
            );
            inputArray = requestData( ...
                this, dbInfo, inputDb ...
                , [requiredNames, optionalNames], range ...
            );
        else
            numY = size(this.C, 1);
            inputArray = nan(numY, numBasePeriods);
        end
        %)
    end%


    function outputDb = hereCreateOutputDb()
        %(
        allNames = [ ...
            this.ObservedNames, this.CommonNames, this.FactorNames ...
            , this.IdiosyncraticResidualNames, this.FactorResidualNames ...
        ];
        meanDb = databank.backend.fromDoubleArrayNoFrills( ...
            [y; cc; f; uu; ee], allNames, range(1) ...
            , [], @all, @Series, "struct", struct() ...
        );

        if opt.MeanOnly
            outputDb = meanDb;
        else
            stdDb = databank.backend.fromDoubleArrayNoFrills( ...
                [Sy; Sc; Sf], allNames(1:numY+numY+numF), range(1) ...
                , [], @all, @Series, "struct", struct() ...
            );
            outputDb.Mean = meanDb;
            outputDb.Std = stdDb;

            factorNames = this.FactorNames;
            factorVector = factorNames;
            for i = 1 : order-1
                factorVector = [factorVector, factorNames + "{" + string(-i) + "}"];
            end
            outputDb.MSE = Series(range(1), covfun.cov2cell(Px, factorVector));
        end
        %)
    end%

end%

