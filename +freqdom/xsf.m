function S = xsf(T,R,~,Z,H,~,U,Omg,nUnit,Freq,Filter,ApplyTo)
% xsf  [Not a public function] Power spectrum generating function for general state space.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

try
    Filter; %#ok<*VUNUS>
catch %#ok<*CTCH>
    Filter = [ ];
end

try
    ApplyTo;
catch
    ApplyTo = [ ];
end

%--------------------------------------------------------------------------

isFilter = ~isempty(Filter) && ~isempty(ApplyTo) && any(ApplyTo);

realSmall = getrealsmall( );
ny = size(Z,1);
[nx,nb] = size(T);
nf = nx - nb;
ne = size(R,2);

Tf = T(1:nf,:);
Rf = R(1:nf,1:ne);
Ra = R(nf+1:end,:);
% Ta11 is an I matrix in difference-stationary models, but not an I matrix
% in I(2) and higher models.
Ta11 = T(nf+(1:nUnit),nf+(1:nUnit));
Ta12 = T(nf+1:nf+nUnit,nUnit+1:end);
Ta22 = T(nf+nUnit+1:end,nUnit+1:end);
SgmAA = Ra*Omg*transpose(Ra);
SgmFF = Rf*Omg*transpose(Rf);
SgmFA = Rf*Omg*transpose(Ra);
if ny > 0
    SgmYY = H*Omg*transpose(H);
end

Freq = Freq(:)';
nFreq = length(Freq);
S = zeros(ny+nf+nb,ny+nf+nb,nFreq);
s = zeros(ny+nf+nb,ny+nf+nb);

status = warning( );
warning('off'); %#ok<WNOFF>
for i = 1 : nFreq
    lmb = Freq(i);
    if isFilter && Filter(i) == 0 && all(ApplyTo) && lmb ~= 0
        continue
    end
    ee = exp(-1i*lmb);
    % F = eye(nf+nb) -  [zeros(nf+nb,nf),T]*exp(-1i*lambda);
    % xxx = F \ Sigmax / ctranspose(F);
    s(ny+1:end,ny+1:end) = doInv( );
    if ny > 0
        s(1:ny,1:ny) = Z*s(ny+nf+1:end,ny+nf+1:end)*transpose(Z) + SgmYY;
        s(1:ny,ny+1:end) = Z*s(ny+nf+1:end,ny+1:end);
        s(ny+1:end,1:ny) = s(ny+1:end,ny+nf+1:end)*transpose(Z);
    end
    if lmb == 0
        % Diffuse y.
        if ny > 0
            yInx = find(any(abs(Z(:,1:nUnit)) > realSmall,2));
            s(yInx,:) = Inf;
            s(:,yInx) = Inf;
        end
        % Diffuse xf.
        xfindex = find(any(abs(Tf(:,1:nUnit)) > realSmall,2));
        s(ny+xfindex,:) = Inf;
        s(:,ny+xfindex) = Inf;
    end
    if ~isempty(U)
        s(ny+nf+1:end,:) = U*s(ny+nf+1:end,:);
        s(:,ny+nf+1:end) = s(:,ny+nf+1:end)*U.';
        if lmb == 0
            % Diffuse xb.
            xbindex = find(any(abs(U(:,1:nUnit)) > realSmall,2));
            s(ny+nf+xbindex,:) = Inf;
            s(:,ny+nf+xbindex) = Inf;
        end
    end
    if isFilter
        s(ApplyTo,:) = Filter(i)*s(ApplyTo,:);
        s(:,ApplyTo) = s(:,ApplyTo)*conj(Filter(i));
    end
    S(:,:,i) = s;
end
warning(status);

% Skip dividing S by 2*pi.

if ~isFilter
    for i = 1 : size(S,1)
        S(i,i,:) = real(S(i,i,:));
    end
end

%**************************************************************************
    function [Sxx,Saa] = doInv( )
        A = Tf*ee;
        % B = inv(eye(nb) - Ta*ee) = inv([A11,A12;0,A22]) where
        %
        % * A11 = eye(nUnit) - Ta11*ee (Ta11 is eye(nUnit) only in
        % diff-stationary models).
        %
        % * A12 = -Ta12*ee.
        %
        % * A21 is zeros.
        %
        % * A22 = eye(nb-nUnit) - Ta22*ee.
        %
        B22 = inv(eye(nb-nUnit) - Ta22*ee);
        if lmb == 0
            % Zero frequency; non-stationary variables not defined here.
            B11 = zeros(nUnit);
            B12 = zeros(nUnit,nb-nUnit);
        else
            % Non-zero frequencies.
            B11 = inv(eye(nUnit) - Ta11*ee);
            d = 1/(1-ee);
            B12 = d*Ta12*B22*ee; %#ok<MINV>
        end
        B = [B11,B12;zeros(nb-nUnit,nUnit),B22];
        Saa = B*SgmAA*ctranspose(B);
        Sfa = SgmFA*ctranspose(B) + A*Saa;
        X = A*B*transpose(SgmFA);
        Sff = SgmFF + X + ctranspose(X) + Tf*Saa*transpose(Tf);
        Sxx = [Sff,Sfa;ctranspose(Sfa),Saa];
    end % doInv( ).

end
