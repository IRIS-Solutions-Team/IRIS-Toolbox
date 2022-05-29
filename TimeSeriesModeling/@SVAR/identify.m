function [this, data, A0, B0, count] = identify(this, data, opt)
% identify  Convert reduced-form VAR to structural VAR
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

ny = size(this.A, 1);
nv = size(this.A, 3);

A = polyn.var2polyn(this.A);
Omega = this.Omega;

this.Std = repmat(opt.std, 1, nv);
this.A0 = repmat(eye(ny), 1, 1, nv);
this.B0 = nan(ny, ny, nv);
this.B = nan(ny, ny, nv);
this.Rank = repmat(Inf, 1, nv);
this.Method = cell(1, nv);

A0 = repmat(eye(ny), 1, 1, nv);
B0 = this.B0;

q = Inf;

count = 1;
switch lower(opt.method)
    case 'chol'
        method = 'Cholesky';
        reorder( );
        for v = 1 : nv
            B0(:, :, v) = chol(Omega(:, :, v)).';
        end
        backorder( );
    case 'qr'
        method = 'QR';
        reorder( );
        C = sum(A, 3);
        for v = 1 : nv
            B0 = transpose(chol(Omega(:, :, v)));
            if rank(C(:, :, 1, v))==ny
                Q = qr(transpose(C(:, :, 1, v)\B0));
            else
                Q = qr(transpose(pinv(C(:, :, 1, v))*B0));
            end
            B0(:, :, v) = B0*Q;
        end
        backorder( );
    case 'svd'
        method = 'SVD';
        q = opt.rank;
        B0 = covfun.orthonorm(Omega, q, opt.std);
        % Recompute covariance matrix of reduced-form residuals if it is
        % reduced rank.
        if q<ny
            var = opt.std .^ 2;
            for v = 1 : nv
                this.Omega(:, :, v) = B0(:, 1:q, v)*transpose(B0(:, 1:q, v))*var;
            end
        end
    case 'householder'
        method = 'Householder';
        % Use Householder transformations to draw random SVARs. Test each SVAR
        % using the Test string to decide whether to keep it or discard.
        if nv>1
            utils.error('SVAR:identify', ...
                ['Cannot run SVAR() with Method=''householder'' on ', ...
                'a VAR object with multiple parameterisation.']);
        end
        if isempty(opt.test)
            utils.error('SVAR:identify', ...
                ['Cannot run SVAR() with Method=''householder'' and ', ...
                'empty Test.']);
        end
        if any(opt.ndraw<=0)
            utils.warning('SVAR:identify', ...
                ['Because NDraw is zero, ', ...
                'empty SVAR object is returned.']);
        end
        [B0, count] = draw(this, opt);
        nv = size(B0, 3);
        A0 = repmat(A0, 1, 1, nv);
        this = alter(this, nv);
end

if opt.std~=1
    B0 = B0 / opt.std;
end

this.A0(:, :, :) = A0;
this.B0(:, :, :) = B0;
this.B(:, :, :) = B0;
this.Rank(:, :) = repmat(q, 1, nv);
this.Method(:, :) = {method};

return


    function reorder( )
        if ~isempty(opt.reorder)
            if iscellstr(opt.reorder) || isstring(opt.reorder)
                list = textual.stringify(opt.reorder);
                nList = numel(list);
                valid = true(1, nList);
                opt.reorder = nan(1, nList);
                for i = 1 : nList
                    pos = strcmp(this.EndogenousNames, list(i));
                    valid(i) = any(pos);
                    if valid(i)
                        opt.reorder(i) = find(pos);
                    end
                end
                if any(~valid)
                    exception.error([
                        "SVAR"
                        "This is not a valid VAR endogenous name: %s"
                    ], list(~valid));
                end
            end
            opt.reorder = reshape(opt.reorder, 1, []);
            if any(isnan(opt.reorder)) ...
                    || length(opt.reorder)~=ny ...
                    || length(intersect(1:ny, opt.reorder))~=ny
                utils.error('SVAR:identify', ...
                    'Invalid reordering vector.');
            end
            A = A(opt.reorder, opt.reorder, :, :);
            Omega = Omega(opt.reorder, opt.reorder, :);
        end
    end


    function backorder( )
        % Put variables (and residuals, if requested) back in order.
        if ~isempty(opt.reorder)
            [~, backOrder] = sort(opt.reorder);
            if opt.backorderresiduals
                B0 = B0(backOrder, backOrder, :);
            else
                B0 = B0(backOrder, :, :);
            end
        end
    end 

end


function [BB, count] = draw(this, Opt)
%
% * Rubio-Ramirez J.F., D.Waggoner, T.Zha (2005) Markov-Switching Structural
% Vector Autoregressions: Theory and Application. FRB Atlanta 2005-27.
%
% * Berg T.O. (2010) Exploring the international transmission of U.S. stock
% price movements. Unpublished manuscript. Munich Personal RePEc Archive
% 23977, http://mpra.ub.uni-muenchen.de/23977.

test = Opt.test;
A = polyn.var2polyn(this.A);
C = sum(A, 3);
invC = inv(C);
ny = size(A, 1);

[h, isy] = myparsetest(this, test);

P = covfun.orthonorm(this.Omega);
count = 0;
maxFound = Opt.ndraw;
maxIter = Opt.MaxIter;
BB = nan(ny, ny, 0);
SS = nan(ny, ny, h, 0);
YY = nan(ny, ny, 0);

% Create command-window progress bar.
if Opt.progress
    pbar = ProgressBar('[IrisToolbox] @VAR/SVAR Progress');
end

nb = 0;
while count<maxIter && nb<maxFound
    count = count + 1;
    % Candidate rotation. Note that we need to call `qr` with two
    % output arguments to get the unitary matrix `Q`.
    [Q, ~] = qr(randn(ny));
    B0 = P*Q;
    % Compute impulse responses T = 1 .. h.
    if h>0
        S = timedom.var2vma(this.A, B0, h);
    else
        S = zeros(ny, ny, 0);
    end
    % Compute asymptotic cum responses.
    if isy
        Y = invC*B0; %#ok<MINV>
    end
    % Test impulse responses, and include successful candidates.
    testAndInclude( );
    nb = size(BB, 3);
    if Opt.progress
        update( pbar, max(count/maxIter, nb/maxFound) );
    end
end

return


    function testAndInclude( )
        try
            pass = isequal(eval(test), true);
            if pass
                BB(:, :, end+1) = B0;
                SS(:, :, :, end+1) = S; %#ok<SETNU>
                if isy
                    YY(:, :, end+1) = Y; %#ok<SETNU>
                end
            else
                % Test minus the structure.
                B0 = -B0;
                S = -S;
                if isy
                    Y = -Y;
                end
                pass = isequal(eval(test), true);
                if pass
                    BB(:, :, end+1) = B0;
                    SS(:, :, :, end+1) = S;
                    if isy
                        YY(:, :, end+1) = Y;
                    end
                end
            end
        catch err
            utils.error('SVAR:identify', ...
                ['Error evaluating the test string ''%s''.\n', ...
                '\tUncle says: %s'], ...
                test, err.message);
        end
    end%
end%

