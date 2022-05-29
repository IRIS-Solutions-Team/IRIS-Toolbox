function [Y, XX, W] = plain(S, isDeviation, A0, Ea, Eu, numPeriods, V)
% simulate.linear.plain  [Not a public function] Plain linear simulation.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%#ok<*VUNUS>
%#ok<*CTCH>

% The input struct S must at least include
%
% * First-order system matrices: T, R, K, Z, H, D
% * Effect of nonlinear equations: Q, v
%

try
    V;
catch
    V = [ ];
end

%--------------------------------------------------------------------------

% First-order solution matrices.
T = S.T;
R = S.R;
K = S.K;
Z = S.Z;
H = S.H;
D = S.D;

ny = size(Z, 1);
nxi = size(T, 1);
nb = size(T, 2);
nf = nxi - nb;
ne = size(Ea, 1);
R0 = R(:, 1:ne);
colR = size(R, 2);
isShkSparse = issparse(Ea);

if isDeviation
    K(:) = 0;
    D(:) = 0;
end

Y = nan(ny, numPeriods);
W = nan(nxi, numPeriods); % W := [xf;alp].

lastEa = max([ 0, find( any( Ea~=0, 1 ), 1, 'last' ) ]);
lastEu = max([ 0, find( any( Eu~=0, 1), 1, 'last' ) ]);

% Nonlinear add-factors.
IsNonlin = ~isempty(V) && ~isempty(S.Q);
if IsNonlin
    Q = S.Q;
    lastN = utils.findlast(V);
    colQ = size(Q, 2);
else
    lastN = 0;
end

% Initial condition.
if isempty(A0)
    wt = zeros(nxi, 1);
else
    wt = [ zeros(nf, 1); A0 ];
end

% __Transition Variables__
for t = 1 : numPeriods
    wt = T*wt(nf+1:end, :) + K;
    if lastEa>=t
        eat = Ea(:, t:lastEa);
        eat = eat(:);
        nAdd = colR - size(eat, 1);
        if isShkSparse
            eat = [ eat; sparse(nAdd, 1) ]; %#ok<AGROW>
        else
            eat = [ eat; zeros(nAdd, 1) ]; %#ok<AGROW>
        end
        wt = wt + R*eat;
    end
    if lastEu>=t
        wt = wt + R0*Eu(:, t);
    end
    if lastN>=t
        vt = V(:, t:lastN);
        vt = vt(:);
        nAdd = colQ - size(vt, 1);
        vt = [ vt; zeros(nAdd, 1) ]; %#ok<AGROW>
        wt = wt + Q*vt;
    end
    W(:, t) = wt;
end

% __Mesurement Variables__
if ny>0
    Y = Z*W(nf+1:end, 1:numPeriods);
    if ~isempty(Ea)
        lastY = min(numPeriods, lastEa);
        Y(:, 1:lastY) = Y(:, 1:lastY) + H*Ea(:, 1:lastY);
    end
    if ~isempty(Eu)
        lastY = min(numPeriods, lastEu);
        Y(:, 1:lastY) = Y(:, 1:lastY) + H*Eu(:, 1:lastY);
    end
    if ~isDeviation && any( D(:)~=0 )
        Y = Y + repmat(D, 1, numPeriods);
    end
end

XX = [ W(1:nf, :); S.U*W(nf+1:end, :) ];

end
