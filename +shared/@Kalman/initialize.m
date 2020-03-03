function s = initialize(s, init, initUnit)
% initialize  Initialize Kalman filter
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

numUnitRoots = s.NumUnitRoots;
numXiB = size(s.Ta, 2);
numStable = numXiB - numUnitRoots;
try
    numE = s.NumE;
catch
    numE = s.ne;
end
inxStable = [false(1, numUnitRoots), true(1, numStable)];
needsTransform = isfield(s, 'U') && ~isempty(s.U);

%
% Fixed Unknown
%
if strcmpi(init, 'FixedUnknown')
    s.InitMean = zeros(numXiB, 1);
    s.InitMseReg = zeros(numXiB);
    s.InitMseInf = [ ];
    s.NumEstimInit = numXiB;
    return
end

%
% Initialize mean
%
s.InitMean = hereInitializeMean( );

%
% Intialize MSE
%
[s.InitMseReg, s.InitMseInf] = hereInitializeMse( );
s.NumEstimInit = hereCountEstimInit( );

return


    function a0 = hereInitializeMean( )
        inxInit = reshape(s.InxInit, [ ], 1);

        a0 = zeros(numXiB, 1);

        if iscell(init) && ~isempty(init) && ~isempty(init{1})
            %
            % User-supplied initial condition
            % Convert Mean[XiB] to Mean[Alpha]
            %
            xb0 = reshape(init{1}, [ ], 1);
            inxZero = isnan(xb0) & ~inxInit;
            xb0(inxZero) = 0;
            if needsTransform
                a0 = s.U(:, :, 1) \ xb0;
            else
                a0 = xb0;
            end
            return
        end

        if ~isempty(s.ka) && any(s.ka(:)~=0) && numStable>0
            %
            % Asymptotic initial condition for the stable part of Alpha;
            % the unstable part is kept at zero initially
            %
            I = eye(numStable);
            a1 = zeros(numUnitRoots, 1);
            a2 = (I - s.Ta(inxStable, inxStable, 1)) \ s.ka(inxStable, 1);
            a0 = [a1; a2];
        end

        if numUnitRoots>0 && isnumeric(initUnit)
            %
            % User supplied data to initialize mean for unit root processes
            % Convert XiB to Alpha
            %
            xb00 = initUnit;
            inxZero = isnan(xb00) & ~inxInit;
            xb00(inxZero) = 0;
            if needsTransform
                a00 = s.U(:, :, 1) \ xb00;
            else
                a00 = xb00;
            end
            a0(1:numUnitRoots) = a00(1:numUnitRoots);
        end
    end%




    function [PaReg, PaInf] = hereInitializeMse( )
        PaReg = zeros(numXiB);
        PaInf = [ ];

        %
        % Fixed initial condition with zero MSE
        %
        if strcmpi(init, 'Fixed')
            return
        end

        %
        % Numerical initial condition supplied by user
        %
        if iscell(init) && numel(init)>=2
            if ~isempty(init{2})
                %
                % User-supplied initial condition including MSE
                % Convert MSE[XiB] to MSE[Alp]
                %
                PaReg(:, :) = init{2};
                if numel(init)>=3 && ~isempty(init{3})
                    PaInf = zeros(numXiB);
                    PaInf(:, :) = init{3};
                end
                if needsTransform
                    U = s.U(:, :, 1);
                    PaReg = (U \ PaReg) / U';
                    if ~isempty(PaInf)
                        PaInf = (U \ PaInf) / U';
                    end
                end
            end
            return
        end

        %
        % Asymptotic distribution
        %
        if any(inxStable)
            % R matrix with rows corresponding to stable Alpha and columns
            % corresponding to transition shocks
            Ra2 = s.Ra(:, 1:numE, 1);
            Ra2 = Ra2(inxStable, s.InxV);
            % Reduced form covariance corresponding to stable alpha. Use the structural
            % shock covariance sub-matrix corresponding to transition shocks only in
            % the pre-sample period
            Sa22 = Ra2 * s.Omg(s.InxV, s.InxV, 1) * Ra2';
            % Compute asymptotic initial condition
            if sum(inxStable)==1
                Pa22 = Sa22 / (1 - s.Ta(inxStable, inxStable, 1).^2);
            else
                Pa22 = covfun.lyapunov(s.Ta(inxStable, inxStable, 1), Sa22);
                Pa22 = (Pa22 + Pa22')/2;
            end
            PaReg(inxStable, inxStable) = Pa22;
        end

        if any(~inxStable)
            if strcmpi(initUnit, 'ApproxDiffuse')
                scale = max(diag(PaReg));
                if isempty(scale) || scale==0
                    if ~isempty(s.Omg)
                        diagOmg = diag(s.Omg(:, :, 1));
                        scale = max(diagOmg(:));
                    else
                        scale = 1;
                    end
                end
                PaInf = zeros(numXiB);
                PaInf(~inxStable, ~inxStable) = eye(numUnitRoots) * scale;
            end
        end
    end%




    function n = hereCountEstimInit( )
        % Number of init conditions estimated as fixed unknowns
        if iscell(init)
            % All init cond supplied by user
            n = 0;
            return
        end
        if strcmpi(initUnit, 'ApproxDiffuse')
            % Initialize unit roots with a large finite MSE matrix
            n = 0;
            return
        end
        if strcmpi(init, 'Fixed')
            n = 0;
            return
        end
        % Estimate fixed initial conditions for unit root processes if the
        % user did not supply data on `'initMeanUnit='` and there is at
        % least one non-stationary measurement variable with at least one
        % observation
        inxObs = any(s.yindex, 2);
        unitZ = s.Z(inxObs, 1:s.NumUnitRoots, 1);
        if any(any( abs(unitZ)>s.MEASUREMENT_MATRIX_TOLERANCE ))
            n = s.NumUnitRoots;
        else
            n = 0;
        end
    end%
end%

