function s = initialize(s, iLoop, opt)
% initialize  Initialize Kalman filter
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

numUnitRoots = s.NUnit;
numXib = s.nb;
numE = s.ne;
inxStable = [false(1, numUnitRoots), true(1, numXib-numUnitRoots)];
transform = ~isempty(s.U);

%
% Initialize mean
%
s.InitMean = hereGetInitMean( );

%
% Intialize MSE
%
if iscell(opt.Init) && numel(opt.Init)==2 && isempty(opt.Init{2})
    % All initial conditions are fixed unknown
    s.InitMse = zeros(numXib);
    s.NInit = numXib;
else
    s.InitMse = hereGetInitMse( );
    s.NInit = hereGetNumInit( );
end

return


    function a0 = hereGetInitMean( )
        inxInit = reshape(s.InxInit, [ ], 1);
        % Initialize mean
        a0 = zeros(numXib, 1);
        if iscell(opt.Init)
            % User-supplied initial condition
            % Convert Mean[Xb] to Mean[Alpha]
            xb0 = opt.Init{1}(:, 1, min(end, iLoop));
            ixZero = isnan(xb0) & ~inxInit;
            xb0(ixZero) = 0;
            if transform
                a0 = s.U(:, :, 1) \ xb0;
            else
                a0 = xb0;
            end
            return
        end
        if ~isempty(s.ka) && any(s.ka(:)~=0)
            % Asymptotic initial condition for the stable part of Alpha;
            % the unstable part is kept at zero initially
            I = eye(numXib - numUnitRoots);
            a1 = zeros(numUnitRoots, 1);
            a2 = (I - s.Ta(inxStable, inxStable, 1)) \ s.ka(inxStable, 1);
            a0 = [a1; a2];
        end
        if numUnitRoots>0 && isnumeric(opt.InitUnitRoot)
            % User supplied data to initialize mean for unit root processes
            % Convert Xb to Alpha
            xb00 = opt.InitUnitRoot(:, 1, min(end, iLoop));
            ixZero = isnan(xb00) & ~inxInit;
            xb00(ixZero) = 0;
            if transform
                a00 = s.U(:, :, 1) \ xb00;
            else
                a00 = xb00;
            end
            a0(1:numUnitRoots) = a00(1:numUnitRoots);
        end
    end%




    function Pa0 = hereGetInitMse( )

        Pa0 = zeros(numXib);

        %
        % Fixed initial condition with zero MSE
        %
        if strcmpi(opt.Init, 'Fixed')
            return
        end

        %
        % Numerical initial condition supplied by user
        %
        if iscell(opt.Init) 
            % User supplied initial condition
            if ~isempty(opt.Init{2})
                % User-supplied initial condition including MSE
                % Convert MSE[Xb] to MSE[Alp]
                Pa0 = opt.Init{2}(:, :, 1, min(end, iLoop));
                if transform
                    Pa0 = s.U(:, :, 1) \ Pa0;
                    Pa0 = Pa0 / transpose(s.U(:, :, 1));
                end
            end
            return
        end

        %
        % Steady-state distribution
        %
        if any(inxStable)
            % R matrix with rows corresponding to stable Alpha and columns
            % corresponding to transition shocks
            RR = s.Ra(:, 1:numE, 1);
            RR = RR(inxStable, s.InxV);
            % Reduced form covariance corresponding to stable alpha. Use the structural
            % shock covariance sub-matrix corresponding to transition shocks only in
            % the pre-sample period
            Sa = RR*s.Omg(s.InxV, s.InxV, 1)*RR.';
            % Compute asymptotic initial condition
            if sum(inxStable)==1
                Pa0stable = Sa / (1 - s.Ta(inxStable, inxStable, 1).^2);
            else
                Pa0stable = covfun.lyapunov(s.Ta(inxStable, inxStable, 1), Sa);
                Pa0stable = (Pa0stable + Pa0stable')/2;
            end
            Pa0(inxStable, inxStable) = Pa0stable;
        end
        if strcmpi(opt.InitUnitRoot, 'ApproxDiffuse')
            if any(inxStable)
                diagStable = diag(Pa0stable);
                maxVar = max(diagStable(:)); % Largest stable variance
            elseif ~isempty(s.Omg)
                diagOmg = diag(s.Omg(:, :, 1));
                maxVar = max(diagOmg(:));
            else
                maxVar = 1;
            end
            Pa0(~inxStable, ~inxStable) = eye(numUnitRoots) * maxVar * s.DIFFUSE_SCALE;

            %{
            Ta_ = s.Ta(~inxStable, :);
            Sigma = s.Ra(:, 1:ne, 1) * s.Omg(:, :, 1) * s.Ra(:, 1:ne, 1)';
            Sigma_ = s.Ra(~inxStable, 1:ne, 1) * s.Omg(:, :, 1) * s.Ra(~inxStable, 1:ne, 1)';
            Ca0 = [ ];
            Pa0_ = Pa0(~inxStable, ~inxStable);
            for i = 1 : 500
                Pa0 = s.Ta*Pa0*s.Ta' + Sigma;
                keyboard
                Pa0_ = Ta_*[Pa0_, Pa0stable]*transpose(Ta_) + Sigma_;
                Ca0 = cat(3, Ca0, covfun.cov2corr(Pa0));
            end
            disp(Pa0)
            disp(maxabs(Pa0(inxStable, inxStable), Pa0stable))
            disp(maxabs(Pa0_, Pa0(~inxStable, ~inxStable)))
            keyboard
            %}
        end
    end%




    function n = hereGetNumInit( )
        % Number of init conditions estimated as fixed unknowns
        if iscell(opt.Init)
            % All init cond supplied by user
            n = 0;
            return
        end
        if strcmpi(opt.InitUnitRoot, 'ApproxDiffuse')
            % Initialize unit roots with a large finite MSE matrix
            n = 0;
            return
        end
        if strcmpi(opt.Init, 'Fixed')
            n = 0;
            return
        end
        % Estimate fixed initial conditions for unit root processes if the
        % user did not supply data on `'initMeanUnit='` and there is at
        % least one non-stationary measurement variable with at least one
        % observation
        inxObs = any(s.yindex, 2);
        unitZ = s.Z(inxObs, 1:s.NUnit, 1);
        if any(any( abs(unitZ)>s.MEASUREMENT_MATRIX_TOLERANCE ))
            n = s.NUnit;
        else
            n = 0;
        end
    end%
end%

