function s = wrapper(~, systemProperty, ~)

s = systemProperty.CallerData;
ny = nnz(s.IxObserved);
ne = nnz(s.IxShocks);

% First-order triangular solution
[s.T, s.R, s.K, s.Z, s.H, s.D, s.U] = systemProperty.FirstOrderTriangular{:};
currentForward = size(s.R, 2)/ne - 1;
if s.RequiredForward>currentForward
    s.R = model.expandFirstOrder(s.R, [ ], systemProperty.FirstOrderExpansion, s.RequiredForward);
end

% Initial condition for alpha
s.Alp0 = s.U\s.XbInit;

yTrend = [ ];
if ny>0 && s.IsDeterministicTrends
    yTrend = evalDeterministicTrends( );
    if s.IsSwap
        % Subtract deterministic trends from measurement tunes.
        s.Tune(1:ny, :) = s.Tune(1:ny, :) - yTrend;
    end
end

if s.IsContributions
    if s.IsSwap
        [s.y, s.xx, s.Ea, s.Eu] = simulate.linear.run(s, Inf);
    end
    [s.y, s.xx, s.Ea, s.Eu] = ...
        simulate.linear.contributions(s, Inf);
else
    [s.y, s.xx, s.Ea, s.Eu] = simulate.linear.run(s, Inf);
end

% Add measurement detereministic trends.
if ~isempty(yTrend)
    % Add to trends to the current simulation; when Contributions=true, we
    % need to add the trends to (ne+1)-th simulation (ie. the contribution of
    % init cond and constant).
    if s.IsContributions
        s.y(:, :, ne+1) = s.y(:, :, ne+1) + yTrend;
    else
        s.y = s.y + yTrend;
    end            
end

if s.IsAnticipate
    e = s.Ea + 1i*s.Eu;
else
    e = s.Eu + 1i*s.Ea;
end

if systemProperty.NumOfOutputs>0
    systemProperty.Outputs{1} = [s.y; s.xx; e];
end

return


    function W = evalDeterministicTrends()
        posy = find(s.IxObserved);
        ixd = ~cellfun(@isempty, s.DeterministicTrend.Equations);
        numPeriods = size(s.ExogenousData, 2);
        W = zeros(ny, numPeriods);
        x = systemProperty.Values;
        x(~s.IxParameters) = NaN;
        x = permute(x, [2, 1]);
        x = repmat(x, 1, numPeriods);
        x(s.IxExogenous, :) = s.ExogenousData;
        for i = find(ixd)
            % This equation gives dtrend for measurement variable ptr.
            ptr = s.DeterministicTrend.Pairing(i);
            % Evaluate deterministic trend with out-of-lik parameters set zero.
            W(posy==ptr, :) = s.DeterministicTrend.Equations{i}(x, ':');
        end
    end%
end%

