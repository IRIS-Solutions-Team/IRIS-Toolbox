% initialize  Initialize Kalman filter
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function s = initialize(s, initial, unitRootInitial, numPreiterate)

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
    U = [];
    if needsTransform
        U = s.U(:, :, 1);
    end

    %
    % Fixed unknown
    %
    if strcmpi(initial, 'FixedUnknown')
        s.InitMean = zeros(numXiB, 1);
        s.InitMseReg = zeros(numXiB);
        s.InitMseInf = [ ];
        s.NumEstimInit = numXiB;
        return
    end

    %
    % Initialize mean
    %
    s.InitMean = here_initializeMean();


    %
    % Intialize MSE
    %
    numPreiterate = max(0, round(numPreiterate));
    [s.InitMseReg, s.InitMseInf] = here_initializeMse();
    s.NumEstimInit = here_countEstimInit();

return

    function a0 = here_initializeMean()
        %(
        inxInit = reshape(s.InxInit, [ ], 1);

        a0 = zeros(numXiB, 1);

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

        if iscell(initial) && ~isempty(initial) && ~isempty(initial{1})
            %
            % User-supplied initial condition
            % Convert Mean[XiB] to Mean[Alpha]
            %
            xiB0 = reshape(double(initial{1}), [ ], 1);

            inxNa = isnan(xiB0);
            if any(inxNa)
                xiB0(inxNa) = U(inxNa, :) * a0;
            end

            % inxZero = isnan(xb0) & ~inxInit;
            % xb0(inxZero) = 0;
            % if any(isnan(xb0))
                % exception.error([
                    % "Kalman"
                    % "Mean of initial condition contaminated with NaNs."
                % ]);
            % end

            if needsTransform
                a0 = U \ xiB0;
            else
                a0 = xiB0;
            end

            return
        end

        if numUnitRoots>0 && isnumeric(unitRootInitial)
            %
            % User supplied data to initialize mean for unit root processes
            % Convert XiB to Alpha
            %
            xiB00 = unitRootInitial;
            inxZero = isnan(xiB00) & ~inxInit;
            xiB00(inxZero) = 0;

            if needsTransform
                a00 = U \ xiB00;
            else
                a00 = xiB00;
            end
            a0(1:numUnitRoots) = a00(1:numUnitRoots);
        end
        %)
    end%


    function [PaReg, PaInf] = here_initializeMse()
        %(
        PaReg = zeros(numXiB);
        PaInf = [];

        %
        % Fixed initial condition with zero MSE
        %
        if strcmpi(initial, 'Fixed')
            return
        end

        %
        % Numerical initial condition supplied by user
        %
        if iscell(initial) && numel(initial)>=2 && ~isempty(initial{2})
            %
            % User-supplied initial condition including MSE
            % Convert MSE[xiB] to MSE[alpha]
            %
            PaReg(:, :) = double(initial{2});
            if numel(initial)>=3 && ~isempty(initial{3})
                PaInf = reshape(double(initial{3}), numXiB, numXiB);
            end
            if needsTransform
                PaReg = (U \ PaReg) / U';
                if ~isempty(PaInf)
                    PaInf = (U \ PaInf) / U';
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
            Omg = s.Omg(s.InxV, s.InxV, 1);
            Sa22 = Ra2 * Omg * Ra2';
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
            if strcmpi(unitRootInitial, 'ApproxDiffuse')
                scale = mean(diag(PaReg));
                if isempty(scale) || scale==0
                    if ~isempty(s.Omg)
                        diagOmg = diag(s.Omg(:, :, 1));
                        scale = mean(diagOmg(:));
                    else
                        scale = 1;
                    end
                end
                scale = scale * s.DIFFUSE_SCALE;
                PaInf = zeros(numXiB);
                PaInf(~inxStable, ~inxStable) = scale * eye(numUnitRoots);
                return
            end

            if strcmpi(unitRootInitial, 'FixedUnknown')
                PaInf = zeros(numXiB);
                return
            end

            if strcmpi(unitRootInitial, 'Preiterate')
                PaInf = zeros(numXiB);
                if numPreiterate==0
                    return
                end

                Ta11 = s.Ta(~inxStable, ~inxStable, 1);
                Ta12 = s.Ta(~inxStable, inxStable, 1);
                Ta22 = s.Ta(inxStable, inxStable, 1);

                Ra1 = s.Ra(~inxStable, 1:numE, 1);
                Sa11 = Ra1 * Omg * Ra1';
                Sa11 = (Sa11 + Sa11')/2;

                Pa22 = PaReg(inxStable, inxStable);
                Pa22 = (Pa22 + Pa22')/2;

                Pa11 = zeros(numUnitRoots);

                for t = 1 : numPreiterate
                    Pa11 = Ta11*Pa11*Ta11' + Ta12*Pa22*Ta12' + Sa11;
                end
                Pa11 = (Pa11 + Pa11')/2;

                PaInf(~inxStable, ~inxStable) = Pa11;
                return
            end
        end
        %)
    end%


    function numEstimInit = here_countEstimInit()
        %(
        % Number of initial conditions estimated as fixed unknowns
        if iscell(initial)
            % All initial cond supplied by user
            numEstimInit = 0;
            return
        end
        if strcmpi(unitRootInitial, 'ApproxDiffuse')
            % Initialize unit roots with a large finite MSE matrix
            numEstimInit = 0;
            return
        end
        if strcmpi(initial, 'Fixed')
            numEstimInit = 0;
            return
        end
        % Estimate fixed initial conditions for unit root processes if the
        % user did not supply data on UnitRootInitials and there is at
        % least one non-stationary measurement variable with at least one
        % observation
        inxObs = any(s.yindex, 2);
        unitZ = s.Z(inxObs, 1:s.NumUnitRoots, 1);
        if any(any( abs(unitZ)>s.MEASUREMENT_MATRIX_TOLERANCE ))
            numEstimInit = s.NumUnitRoots;
        else
            numEstimInit = 0;
        end
        %)
    end%

end%

