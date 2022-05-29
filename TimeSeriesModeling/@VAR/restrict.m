function [Rr, Qq] = restrict(numEndogenous, numIntercepts, numExogenous, numCointeg, opt)
% restrict  Convert parameter restrictions to hyperparameter matrix form
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%#ok<*CTCH>

%--------------------------------------------------------------------------

if isempty(opt.Constraints) ...
        && isempty(opt.A) ...
        && isempty(opt.C) ...
        && isempty(opt.J) ...
        && isempty(opt.G)
    Rr = [ ];
    Qq = [ ];
end

if isnumeric(opt.Constraints)
    Rr = opt.Constraints;
    if nargout>1
        Qq = convertR2Q(Rr);
    end
    return
end

order = opt.Order;
if opt.Diff
    order = order - 1;
end

numBetas = numEndogenous*(numIntercepts+numExogenous+numEndogenous*order+numCointeg);
Q = zeros(0, numBetas);
q = zeros(0);

isPlain = ~isempty(opt.A) ...
    || ~isempty(opt.C) ...
    || ~isempty(opt.J) ...
    || ~isempty(opt.G);

% General constraints.
rest = lower(strtrim(opt.Constraints));
if ~isempty(rest)
    rest = textual.convertEndOfLines(rest);
    rest = strrep(rest, char(10), ' ');
    rest = lower(rest);
    % Convert char to cellstr: for bkw compatibility, char strings can use
    % semicolons to separate individual restrictions.
    if ischar(rest)
        rest = { rest };
    end
    % Convert restrictions to implicit forms: `A=B` to `A-B`.
    rest = regexprep(rest, '=(.*)', '-\($1\)');
    % Vectorize and vertically concatenate all general restrictions.
    rest = strcat('vectorize(', rest, ');');
    rest = ['[', rest{:}, ']'];
end

% A, C, G restrictions.
if ~isempty(rest)
    % General constraints exist. Set up (Q, q) first for general and plain
    % constraints, then convert them to (R, r).
    restFn = eval(['@(c, j, a, g) ', rest, ';']);
    [Q1, q1] = general(restFn, numEndogenous, numIntercepts, numExogenous, numCointeg, order);
    Q = [Q;Q1];
    q = [q;q1];
    % Plain constraints.
    if isPlain
        [Q2, q2] = plainQ(opt, numEndogenous, numIntercepts, numExogenous, numCointeg, order);
        Q = [Q;Q2];
        q = [q;q2];
    end
    % Convert Q*beta + q = 0 to beta = R*gamma + r, 
    % where gamma is a vector of free hyperparameters.
    if ~isempty(Q)
        Rr = convertQ2R([Q, q]);
    end
    if nargout > 1
        Qq = sparse([Q, q]);
    end
elseif isPlain
    [R, r] = plainR(opt, numEndogenous, numIntercepts, numExogenous, numCointeg, order);
    Rr = sparse([R, r]);
    if nargout > 1
        Qq = convertR2Q(Rr);
    end
end

end


function [Q, q] = general(funcRest, numEndogenous, numIntercepts, numExogenous, numCointeg, order)
    % Q*beta = q
    numRhs = numEndogenous*order + numIntercepts + numExogenous + numCointeg; 
    aux = reshape(transpose(1:numEndogenous*numRhs), [numEndogenous, numRhs]);
    cPos = aux(:, 1:numIntercepts);
    aux(:, 1:numIntercepts) = [ ];
    dPos = aux(:, 1:numExogenous);
    aux(:, 1:numExogenous) = [ ];
    aPos = reshape(aux(:, 1:numEndogenous*order), [numEndogenous, numEndogenous, order]);
    aux(:, 1:numEndogenous*order) = [ ];
    gPos = aux;
    c = zeros(size(cPos)); % Constant.
    j = zeros(size(dPos)); % Exogenous inputs.
    a = zeros(size(aPos)); % Transition matrix.
    g = zeros(size(gPos)); % Cointegrating vector.
    % Q*beta + q = 0.
    try
        q = funcRest(c, j, a, g);
    catch Error
        utils.error('VAR', ...
            ['Error evaluating parameter restrictions.\n', ...
            '\Uncle says: %s'], ...
            Error.message);
    end
    nRest = size(q, 1);
    Q = zeros(nRest, numEndogenous*numRhs);
    for i = 1 : numel(c)
        c(i) = 1;
        Q(:, cPos(i)) = funcRest(c, j, a, g) - q;
        c(i) = 0;
    end
    for i = 1 : numel(j)
        j(i) = 1;
        Q(:, dPos(i)) = funcRest(c, j, a, g) - q;
        j(i) = 0;
    end
    for i = 1 : numel(a)
        a(i) = 1;
        Q(:, aPos(i)) = funcRest(c, j, a, g) - q;
        a(i) = 0;
    end
    for i = 1 : numel(g)
        g(i) = 1;
        Q(:, gPos(i)) = funcRest(c, j, a, g) - q;
        g(i) = 0;
    end
end


function [Q, q] = plainQ(opt, numEndogenous, numIntercepts, numExogenous, numCointeg, order)
    [A, C, J, G] = assignPlain(opt, numEndogenous, numIntercepts, numExogenous, numCointeg, order);
    numRhs = numEndogenous*order + numIntercepts + numExogenous + numCointeg; 
    numBetas = numEndogenous*numRhs;
    % Construct parameter restrictions first, 
    % Q*beta + q = 0, 
    % splice them with the general restrictions
    % and only then convert these to hyperparameter form.
    Q = eye(numBetas);
    q = -[C, J, A(:, :), G];
    q = q(:);
    inx = ~isnan(q);
    Q = Q(inx, :);
    q = q(inx);
end 


function [R, r] = plainR(opt, numEndogenous, numIntercepts, numExogenous, numCointeg, order)
    [A, C, J, G] = assignPlain(opt, numEndogenous, numIntercepts, numExogenous, numCointeg, order);
    numBetas = numEndogenous*(numIntercepts+numExogenous+numEndogenous*order+numCointeg);
    % Construct directly hyperparameter form:
    % beta = R*gamma + r.
    R = eye(numBetas);
    r = [C, J, A(:, :), G];
    r = r(:);
    inx = ~isnan(r);
    R(:, inx) = [ ];
    r(~inx) = 0;
end


function [A, C, J, G] = assignPlain(opt, numEndogenous, numIntercepts, numExogenous, numCointeg, order)
    A = nan(numEndogenous, numEndogenous, order);
    C = nan(numEndogenous, numIntercepts);
    J = nan(numEndogenous, numExogenous);
    G = nan(numEndogenous, numCointeg);
    if ~isempty(opt.A)
        try
            A(:, :, :) = opt.A;
        catch
            utils.error('VAR', ...
                ['Error setting up VAR restrictions for matrix A. ', ...
                'Size of the matrix must be %s.'], ...
                sprintf('%g-by-%g-by-%g', numEndogenous, numEndogenous, order));
        end
    end
    if ~isempty(opt.C)
        try
            C(:, :) = opt.C;
        catch
            utils.error('VAR', ...
                ['Error setting up VAR restrictions for matrix C. ', ...
                'Size of the matrix must be %s.'], ...
                sprintf('%g-by-%g', numEndogenous, numIntercepts));
        end
    end
    if ~isempty(opt.J)
        try
            J(:, :) = opt.J;
        catch
            utils.error('VAR', ...
                ['Error setting up VAR restrictions for matrix J. ', ...
                'Size of the matrix must be %s.'], ...
                sprintf('%g-by-%g', numEndogenous, numExogenous));
        end
    end
    if ~isempty(opt.G)
        try
            G(:, :) = opt.G;
        catch
            utils.error('VAR', ...
                ['Error setting up VAR restrictions for matrix G. ', ...
                'Size of the matrix must be %s.'], ...
                sprintf('%g-by-%g-by-%g', numEndogenous, numCointeg));
        end
    end
end


function X = vectorize(X) %#ok<DEFNU>
    X = X(:);
end 


function RR = convertQ2R(QQ)
% convertQ2R  Convert Q-restrictions to R-restrictions.
    Q = QQ(:, 1:end-1);
    q = QQ(:, end);
    R = null(Q);
    r = -pinv(Q)*q;
    RR = sparse([R, r]);
end


function QQ = convertR2Q(RR)
% convertR2Q  Convert R-restrictions to Q-restrictions when they are unknown
    R = RR(:, 1:end-1);
    r = RR(:, end);
    Q = null(R.').';
    q = -Q*r;
    QQ = sparse([Q, q]);
end 

