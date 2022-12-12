% simulate  Simulate VAR model
%{
% __Syntax__
%
%     Outp = simulate(V, Inp, Range, ...)
%
%
% __Input Arguments__
%
% * `V` [ VAR ] - VAR object that will be simulated.
%
% * `Inp` [ struct ] - Input databank from which the initial condtions and
% residuals will be taken.
%
% * `Range` [ DateWrapper ] - Simulation range; must not be `Inf`.
%
%
% __Output Arguments__
%
% * `Outp` [ tseries ] - Output databank with simulated time series.
%
%
% __Options__
%
% * `AppendPresample=false` [ `true` | `false` | struct ] - Append
% presample data from input databank.
%
% * `Contributions=false` [ `true` | `false` ] - Decompose the simulated
% paths into the contributions of individual residuals, initial condition,
% the constant, and exogenous inputs; see Description.
%
% * `Deviation=false` [ `true` | `false` ] - Treat input and output data as
% deviations from unconditional mean.
%
%
% __Description__
%
% _Backward Simulation_
%
% If the `Range` is a vector of decreasing dates, the simulation is
% performed backward. The VAR object is first converted to its backward
% representation using the function [`backward`](VAR/backward), and then
% the data are simulated from the latest date to the earliest date.
%
%
% _Simulation of Contributions__
%
% With the option `'contributions=' true`, the output database contains
% Ne+2 columns for each variable, where Ne is the number of residuals. The
% first Ne columns are the contributions of the individual shocks, the
% (Ne+1)-th column is the contribution of initial condition and the
% constant, and the last, (Ne+2)-th columns is the contribution of
% exogenous inputs.
%
% Contribution simulations can be only run on VAR objects with one
% parameterization.
%
%
% __Example__
%
%}
% --8<--

function outputDb = simulate(this, inputDb, range, varargin)

% Panel VAR model
if this.IsPanel
    outputDb = runGroups(@simulate, this, inputDb, range, varargin{:});
    return
end

%( Input parser
persistent ip
if isempty(ip)
    ip = inputParser();
    addParameter(ip, "PrependInput", false);
        addParameter(ip, "AppendPresample__PrependInput", []);
    addParameter(ip, "AppendInput", false);
        addParameter(ip, "AppendPostsample__AppendInput", []);
    addParameter(ip, 'Deviation', false, @(x) isequal(x, true) || isequal(x, false));
    addParameter(ip, 'Contributions', false, @(x) isequal(x, true) || isequal(x, false));
end
parse(ip, varargin{:});
opt = ip.Results;
%)

opt = iris.utils.resolveOptionAliases(opt, [], true);


    numY = this.NumEndogenous;
    numG = this.NumExogenous;
    numE = this.NumResiduals;
    inxY = [true(numY, 1); false(numG, 1); false(numE, 1)];
    inxG = [false(numY, 1);  true(numG, 1); false(numE, 1)];
    inxE = [false(numY, 1); false(numG, 1);  true(numE, 1)];

    nv = countVariants(this);
    order = this.Order;


    [extdStart, extdEnd] = getExtendedRange(this, range);
    extdRange = dater.colon(extdStart, extdEnd);
    if isempty(extdRange)
        return
    end
    numExtdPeriods = numel(extdRange);


    [YGE, dbInfo] = here_requestData();
    numRuns = max(nv, dbInfo.NumPages);


    if opt.Contributions
        if numRuns~=1
            exception.error([
                "VAR:CannotSimulateContributions"
                "Cannot simulate shock contributions in VAR with multiple parameter variants"
            ]);
        end
        numRuns = numY + 2;
    end


    if dbInfo.NumPages<numRuns
        numAdd = numRuns - dbInfo.NumPages;
        YGE(:, :, end+1:numRuns) = repmat(YGE(:, :, end), 1, 1, numAdd);
    end


    %if opt.Contributions
    %    y(:, :, [1:end-2, end]) = 0;
    %    x(:, :, 1:end-1) = 0;
    %end

    %if ~opt.Contributions
    %    outp1 = hdataobj(this, extdRange, numRuns);
    %else
    %    outp1 = hdataobj(this, extdRange, numRuns, 'Contributions=', @shock);
    %end


    % =========================================================================
    for run = 1 : numRuns
        if run<=nv
            [A, B, K, J] = getIthSystem(this, run);
        end

        Y__ = YGE(inxY, :, run);
        G__ = YGE(inxG, :, run);
        E__ = YGE(inxE, :, run);
        E__(isnan(E__)) = 0;
        E__(:, 1:order-1) = NaN;

        includeConstant = ~opt.Deviation;
        if opt.Contributions
            if run<=numY
                % Contributions of shock i
                inx = true(1, numY);
                inx(run) = false;
                %e(inx, :, run) = 0;
                E__(inx, :) = 0;
                Y__(:, :) = 0;
                G__(:, :) = 0;
                includeConstant = false;
            elseif run==numY+1
                % Contributions of init and const
                %e(:, :, run) = 0;
                E__(:, :) = 0;
                G__(:, :) = 0;
                includeConstant = true;
            elseif run==numY+2
                % Contributions of exogenous variables
                %e(:, :, run) = 0;
                E__(:, :) = 0;
                Y__(:, :) = 0;
                includeConstant = false;
            end
        end

        %iE = e(:, :, run);
        if isempty(B)
            %iBe = iE;
            ithBE = E__;
        else
            %iBe = B*iE;
            ithBE = B*E__;
        end

        % Collect deterministic terms (constant, exogenous inputs).
        ithDeterministic = zeros(numY, numExtdPeriods);
        if includeConstant
            ithDeterministic = ithDeterministic + K(:, ones(1, numExtdPeriods));
        end

        if numG>0
            ithDeterministic = ithDeterministic + J*G__;
        end

        for t = order + 1 : numExtdPeriods
            stackLags = Y__(:, t-(1:order));
            Y__(:, t) = A*stackLags(:) + ithDeterministic(:, t) + ithBE(:, t);
        end

        % Assign current results.
        YGE(:, :, run) = [Y__; E__; G__];
    end
    % =========================================================================


    % Create output database
    outputDb = returnData(this, YGE, extdRange, dbInfo.AllNames);
    outputDb = appendData(this, inputDb, outputDb, range, opt);

    return


        function [YGE, dbInfo] = here_requestData()
            %(
            % Check availability of input data in input databank
            requiredNames = [this.EndogenousNames, this.ExogenousNames];
            optionalNames = this.ResidualNames;
            allowedNumeric = string.empty(1, 0);
            allowedLog = string.empty(1, 0);
            context = "";
            dbInfo = checkInputDatabank( ...
                this, inputDb, extdRange ...
                , requiredNames, optionalNames ...
                , allowedNumeric, allowedLog ...
                , context ...
            );


            % Retrieve a YGE data array from the input databank
            YGE = requestData( ...
                this, dbInfo, inputDb ...
                , [requiredNames, optionalNames], extdRange ...
            );
            %)
        end%
end%


