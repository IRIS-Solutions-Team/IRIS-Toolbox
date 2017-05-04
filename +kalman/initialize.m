function s = initialize(s, iLoop, opt)
% initialize  Initialize Kalman filter.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

nUnit = s.NUnit;
nb = s.nb;
ne = s.ne;
ixStable = [false(1, nUnit), true(1, nb-nUnit)];

s.InitMean = getInitMean( );
s.InitMse = getInitMse( );
s.NInit = getNInit( );

return




    function a0 = getInitMean( )
        % Initialize mean.
        a0 = zeros(nb, 1);
        if iscell(opt.Init)
            % User-supplied initial condition.
            % Convert Mean[Xb] to Mean[Alpha].
            xb0 = opt.Init{1}(:, 1, min(end, iLoop));
            ixZero = isnan(xb0) & ~s.IxRequired(:);
            xb0(ixZero) = 0;
            a0 = s.U \ xb0;
            return
        end
        if ~isempty(s.ka) && any(s.ka(:)~=0)
            % Asymptotic initial condition for the stable part of Alpha;
            % the unstable part is kept at zero initially.
            I = eye(nb - nUnit);
            a1 = zeros(nUnit, 1);
            a2 = (I - s.Ta(ixStable, ixStable)) \ s.ka(ixStable, 1);
            a0 = [a1; a2];
        end
        if nUnit>0 && isnumeric(opt.InitUnitRoot)
            % User supplied data to initialise mean for unit root processes.
            % Convert Xb to Alpha.
            xb00 = opt.InitUnitRoot(:, 1, min(end, iLoop));
            ixZero = isnan(xb00) & ~s.IxRequired(:);
            xb00(ixZero) = 0;
            a00 = s.U \ xb00;
            a0(1:nUnit) = a00(1:nUnit);
        end
    end




    function Pa0 = getInitMse( )
        % Initialise MSE matrix.
        Pa0 = zeros(nb);
        if iscell(opt.Init) 
            % User supplied initial condition.
            if ~isempty(opt.Init{2})
                % User-supplied initial condition including MSE.
                % Convert MSE[Xb] to MSE[Alp].
                Pa0 = opt.Init{2}(:, :, 1, min(end, iLoop));
                Pa0 = s.U \ Pa0;
                Pa0 = Pa0 / s.U.';
            end
            return
        end
        if any(ixStable)
            % R matrix with rows corresponding to stable Alpha and columns
            % corresponding to transition shocks.
            RR = s.Ra(:, 1:ne);
            RR = RR(ixStable, s.IxEt);
            % Reduced form covariance corresponding to stable alpha. Use the structural
            % shock covariance sub-matrix corresponding to transition shocks only in
            % the pre-sample period.
            Sa = RR*s.Omg(s.IxEt, s.IxEt, 1)*RR.';
            % Compute asymptotic initial condition.
            if sum(ixStable)==1
                Pa0stable = Sa / (1 - s.Ta(ixStable, ixStable).^2);
            else
                Pa0stable = ...
                    covfun.lyapunov(s.Ta(ixStable, ixStable),Sa);
                Pa0stable = (Pa0stable + Pa0stable.')/2;
            end
            Pa0(ixStable, ixStable) = Pa0stable;
        end
        if strcmpi(opt.InitUnitRoot, 'ApproxDiffuse')
            if any(ixStable)
                diagStable = diag(Pa0stable);
                maxVar = max(diagStable(:)); % Largest stable variance.
            elseif ~isempty(s.Omg)
                diagOmg = diag(s.Omg(:, :, 1));
                maxVar = max(diagOmg(:));
            else
                maxVar = 1;
            end
            Pa0(~ixStable, ~ixStable) = eye(nUnit) * maxVar * s.DIFFUSE_SCALE;
        end
    end




    function n = getNInit( )
        % Number of init conditions estimated as fixed unknowns
        if iscell(opt.Init)
            % All init cond supplied by user.
            n = 0;
            return
        end
        if strcmpi(opt.InitUnitRoot, 'ApproxDiffuse')
            % Initialize unit roots with a large finite MSE matrix.
            n = 0;
            return
        end
        % Estimate fixed initial conditions for unit root processes if the
        % user did not supply data on `'initMeanUnit='` and there is at
        % least one non-stationary measurement variable with at least one
        % observation.
        ixObs = any(s.yindex, 2);
        z = s.Z(ixObs, 1:s.NUnit);
        if any(any( abs(z)>s.EIGEN_TOLERANCE ))
            n = s.NUnit;
        else
            n = 0;
        end
    end
end
