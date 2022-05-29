function [Y,W,E] = simulatemean(T,R,K,Z,H,D,~,A0,E,Nper,Ant,Dev,Q,q)
% simulatemean  [Not a public function] Simulate mean in general state space.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

% TODO: Simplify treatment of ea and eu.

%#ok<*VUNUS>
%#ok<*CTCH>

try
    Q; 
catch
    Q = [ ];
end

try
    q;
catch
    q = [ ];
end

isnonlin = ~isempty(Q) && ~isempty(q);

if Ant
    anticipated = @real;
    unanticipated = @imag;
else
    anticipated = @imag;
    unanticipated = @real;
end    

%--------------------------------------------------------------------------

ny = size(Z,1);
[nx,nb] = size(T);
nf = nx - nb;
ne = size(E,1);

Y = nan(ny,Nper);
W = nan(nx,Nper); % := [xf;a]
ea = anticipated(E);
eu = unanticipated(E);

lastea = utils.findlast(ea);
lasteu = utils.findlast(eu);
ia = any(abs(R(:,1:ne*lastea)) > 0,1);
iu = any(abs(R(:,1:ne)) > 0,1);

if isnonlin
    nn = size(q,1);
    lastn = utils.findlast(q);
    in = any(abs(Q(:,1:nn*lastn)) > 0,1);
end

for t = 1 : Nper
    if t == 1
        W(:,t) = T*A0;
    else
        W(:,t) = T*W(nf+1:end,t-1);
    end
    if ~Dev
        W(:,t) = W(:,t) + K;
    end
    if lastea > 0 && any(ia)
        eat = ea(:,t:t+lastea-1);
        eat = eat(:);
        W(:,t) = W(:,t) + R(:,ia)*eat(ia);
        lastea = lastea - 1;
        ia = ia(1,1:end-ne);
    end
    if lasteu > 0 && any(iu)
        W(:,t) = W(:,t) + R(:,iu)*eu(iu,t);
        lasteu = lasteu - 1;
    end
    if isnonlin && lastn > 0 && any(in)
        qt = q(:,t:t+lastn-1);
        qt = qt(:);
        W(:,t) = W(:,t) + Q(:,in)*qt(in);
        lastn = lastn - 1;
        in = in(1,1:end-nn);
    end
end

% Mesurement variables.
if ny > 0
    Y = Z*W(nf+1:end,1:Nper) +...
        H*(eu(:,1:Nper) + ea(:,1:Nper));
    if ~Dev
        Y = Y + D(:,ones(1,Nper));
    end
end

end
