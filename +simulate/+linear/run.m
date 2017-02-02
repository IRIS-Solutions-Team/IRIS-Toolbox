function [Y,Xx,Ea,Eu,W] = run(S,NPer,V)
% simulate.linear.run  [Not a public function] Linear simulation.
%
% Backed IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

try
    V; %#ok<VUNUS>
catch
    V = [ ];
end

%--------------------------------------------------------------------------

ny = size(S.Z, 1);
nxx = size(S.T, 1);

if isequal(NPer, Inf)
    NPer = size(S.Ea, 2);
end

isAnch = ~isempty(S.Anch) && any(S.Anch(:));

if ~isAnch
    % Plain simulation
    %------------------
    Ea = S.Ea;
    Eu = S.Eu;
    [Y,Xx,W] = simulate.linear.plain(S,S.IsDeviation,S.Alp0,Ea,Eu,NPer,V);
else
    % Simulation with exogenized variables
    %--------------------------------------
    % Exogenised simulation.
    % Plain simulation first.
    lastExg = max([ 0, find(any(S.Anch(1:ny+nxx,:),1),1,'last') ]);
    [S.y,S.x] = simulate.linear.plain(S, ...
        S.IsDeviation,S.Alp0,S.Ea,S.Eu,lastExg,V);

    % Multipliers of endogenized shocks.
    if isempty(S.M)
        S.M = simulate.linear.multipliers(S);
    end
    
    % Back out add-factors and add them to current shocks.
    yxx = [ S.y; S.x ];
    [Ea,Eu] = simulate.linear.exogenize(S,S.M,yxx,S.Ea,S.Eu);

    % Re-simulate with endogenized shocks added.
    [Y,Xx,W] = simulate.linear.plain(S,S.IsDeviation,S.Alp0,Ea,Eu,NPer,V);
end

end
