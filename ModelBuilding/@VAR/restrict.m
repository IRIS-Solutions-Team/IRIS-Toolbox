function [Rr,Qq] = restrict(Ny,Nk,Nx,Ng,Opt)
% restrict  [Not a public function] Convert parameter restrictions to hyperparameter matrix form.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%#ok<*CTCH>

%--------------------------------------------------------------------------

if isempty(Opt.constraints) ...
        && isempty(Opt.a) ...
        && isempty(Opt.c) ...
        && isempty(Opt.j) ...
        && isempty(Opt.g)
    Rr = [ ];
    Qq = [ ];
end

if isnumeric(Opt.constraints)
    Rr = Opt.constraints;
    if nargout > 1
        Qq = xxRr2Qq(Rr);
    end
    return
end

nLag = Opt.order;
if Opt.diff
    nLag = nLag - 1;
end

nBeta = Ny*(Nk+Nx+Ny*nLag+Ng);
Q = zeros(0,nBeta);
q = zeros(0);

isPlain = ~isempty(Opt.a) ...
    || ~isempty(Opt.c) ...
    || ~isempty(Opt.j) ...
    || ~isempty(Opt.g);

% General constraints.
rest = lower(strtrim(Opt.constraints));
if ~isempty(rest)
    rest = textfun.converteols(rest);
    rest = strrep(rest, char(10),' ');
    rest = lower(rest);
    % Convert char to cellstr: for bkw compatibility, char strings can use
    % semicolons to separate individual restrictions.
    if ischar(rest)
        rest = { rest };
    end
    % Convert restrictions to implicit forms: `A=B` to `A-B`.
    rest = regexprep(rest, '=(.*)', '-\($1\)');
    % Vectorize and vertically concatenate all general restrictions.
    rest = strcat('xxVec(', rest, ');');
    rest = ['[', rest{:}, ']'];
end

% A, C, G restrictions.
if ~isempty(rest)
    % General constraints exist. Set up (Q,q) first for general and plain
    % constraints, then convert them to (R,r).
    restFn = eval(['@(c,j,a,g) ',rest,';']);
    [Q1,q1] = xxGeneral(restFn,Ny,Nk,Nx,Ng,nLag);
    Q = [Q;Q1];
    q = [q;q1];
    % Plain constraints.
    if isPlain
        [Q2,q2] = xxPlainQq(Opt,Ny,Nk,Nx,Ng,nLag);
        Q = [Q;Q2];
        q = [q;q2];
    end
    % Convert Q*beta + q = 0 to beta = R*gamma + r,
    % where gamma is a vector of free hyperparameters.
    if ~isempty(Q)
        Rr = xxQq2Rr([Q,q]);
    end
    if nargout > 1
        Qq = sparse([Q,q]);
    end
elseif isPlain
    [R,r] = xxPlainRr(Opt,Ny,Nk,Nx,Ng,nLag);
    Rr = sparse([R,r]);
    if nargout > 1
        Qq = xxRr2Qq(Rr);
    end
end

end


% Subfunctions...


%**************************************************************************


function [Q,q] = xxGeneral(RestFn,Ny,Nk,Nx,Ng,NLag)
% Q*beta = q
aux = reshape(transpose(1:Ny*(Nk+Nx+Ny*NLag+Ng)),[Ny,Nk+Nx+Ny*NLag+Ng]);
cPos = aux(:,1:Nk);
aux(:,1:Nk) = [ ];
dPos = aux(:,1:Nx);
aux(:,1:Nx) = [ ];
aPos = reshape(aux(:,1:Ny*NLag),[Ny,Ny,NLag]);
aux(:,1:Ny*NLag) = [ ];
gPos = aux;
c = zeros(size(cPos)); % Constant.
j = zeros(size(dPos)); % Exogenous inputs.
a = zeros(size(aPos)); % Transition matrix.
g = zeros(size(gPos)); % Cointegrating vector.
% Q*beta + q = 0.
try
    q = RestFn(c,j,a,g);
catch Error
    utils.error('VAR', ...
        ['Error evaluating parameter restrictions.\n', ...
        '\Uncle says: %s'], ...
        Error.message);
end
nRest = size(q,1);
Q = zeros(nRest,Ny*(Nk+Nx+Ny*NLag+Ng));
for i = 1 : numel(c)
    c(i) = 1;
    Q(:,cPos(i)) = RestFn(c,j,a,g) - q;
    c(i) = 0;
end
for i = 1 : numel(j)
    j(i) = 1;
    Q(:,dPos(i)) = RestFn(c,j,a,g) - q;
    j(i) = 0;
end
for i = 1 : numel(a)
    a(i) = 1;
    Q(:,aPos(i)) = RestFn(c,j,a,g) - q;
    a(i) = 0;
end
for i = 1 : numel(g)
    g(i) = 1;
    Q(:,gPos(i)) = RestFn(c,j,a,g) - q;
    g(i) = 0;
end
end % xxGeneralRest( )


%**************************************************************************


function [Q,q] = xxPlainQq(Opt,Ny,Nk,Nx,Ng,NLag)
[A,C,J,G] = xxAssignPlain(Opt,Ny,Nk,Nx,Ng,NLag);
nBeta = Ny*(Nk+Nx+Ny*NLag+Ng);
% Construct parameter restrictions first,
% Q*beta + q = 0,
% splice them with the general restrictions
% and only then convert these to hyperparameter form.
Q = eye(nBeta);
q = -[C,J,A(:,:),G];
q = q(:);
inx = ~isnan(q);
Q = Q(inx,:);
q = q(inx);
end % xxPlainRest1( )


%**************************************************************************


function [R,r] = xxPlainRr(Opt,Ny,Nk,Nx,Ng,NLag)
[A,C,J,G] = xxAssignPlain(Opt,Ny,Nk,Nx,Ng,NLag);
nbeta = Ny*(Nk+Nx+Ny*NLag+Ng);
% Construct directly hyperparameter form:
% beta = R*gamma + r.
R = eye(nbeta);
r = [C,J,A(:,:),G];
r = r(:);
inx = ~isnan(r);
R(:,inx) = [ ];
r(~inx) = 0;
end % xxPlainRest2( )


%**************************************************************************
function [A,C,J,G] = xxAssignPlain(Opt,Ny,Nk,Nx,Ng,NLag)
A = nan(Ny,Ny,NLag);
C = nan(Ny,Nk);
J = nan(Ny,Nx);
G = nan(Ny,Ng);
if ~isempty(Opt.a)
    try
        A(:,:,:) = Opt.a;
    catch
        utils.error('VAR', ...
            ['Error setting up VAR restrictions for matrix A. ',...
            'Size of the matrix must be %s.'], ...
            sprintf('%g-by-%g-by-%g',Ny,Ny,NLag));
    end
end
if ~isempty(Opt.c)
    try
        C(:,:) = Opt.c;
    catch
        utils.error('VAR', ...
            ['Error setting up VAR restrictions for matrix C. ',...
            'Size of the matrix must be %s.'], ...
            sprintf('%g-by-%g',Ny,Nk));
    end
end
if ~isempty(Opt.j)
    try
        J(:,:) = Opt.j;
    catch
        utils.error('VAR', ...
            ['Error setting up VAR restrictions for matrix J. ',...
            'Size of the matrix must be %s.'], ...
            sprintf('%g-by-%g',Ny,Nx));
    end
end
if ~isempty(Opt.g)
    try
        G(:,:) = Opt.g;
    catch
        utils.error('VAR', ...
            ['Error setting up VAR restrictions for matrix G. ',...
            'Size of the matrix must be %s.'], ...
            sprintf('%g-by-%g-by-%g',Ny,Ng));
    end
end
end % xxAssignPlainRest( )


%**************************************************************************


function X = xxVec(X) %#ok<DEFNU>
X = X(:);
end % xxVec( )


%**************************************************************************


function RR = xxQq2Rr(QQ)
% xxRr2Qq  Convert Q-restrictions to R-restrictions.
Q = QQ(:,1:end-1);
q = QQ(:,end);
R = null(Q);
r = -pinv(Q)*q;
RR = sparse([R,r]);
end % xxQq2Rr( )


%**************************************************************************


function QQ = xxRr2Qq(RR)
% xxRr2Qq  Convert R-restrictions to Q-restrictions when they are unknown.
R = RR(:,1:end-1);
r = RR(:,end);
Q = null(R.').';
q = -Q*r;
QQ = sparse([Q,q]);
end % xxRr2Qq( )
