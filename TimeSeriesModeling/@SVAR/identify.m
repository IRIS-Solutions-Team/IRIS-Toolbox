% identify  Convert reduced-form VAR to structural VAR

function [this, data, A0, B0, count] = identify(this, data, opt)

    ny = size(this.A, 1);
    nv = size(this.A, 3);

    A = polyn.var2polyn(this.A);
    Omega = this.Omega;

    this.Std = repmat(opt.Std, 1, nv);
    this.A0 = repmat(eye(ny), 1, 1, nv);
    this.B0 = nan(ny, ny, nv);
    this.B = nan(ny, ny, nv);
    this.Rank = repmat(Inf, 1, nv);
    this.Method = cell(1, nv);

    A0 = repmat(eye(ny), 1, 1, nv);
    B0 = this.B0;

    q = Inf;

    count = 1;
    switch lower(char(opt.Method))
        case 'chol'
            method = 'Cholesky';
            [A, Omega] = local_reorder(A, Omega, opt.Reorder, this.EndogenousNames);
            for v = 1 : nv
                B0(:, :, v) = chol(Omega(:, :, v)).';
            end
            B0 = local_backorder(B0, opt.Reorder, opt.BackorderResiduals);
        case 'qr'
            method = 'QR';
            [A, Omega] = local_reorder(A, Omega, opt.Reorder, this.EndogenousNames);
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
            B0 = local_backorder(B0, opt.Reorder, opt.BackorderResiduals);
        case 'svd'
            method = 'SVD';
            q = opt.Rank;
            B0 = covfun.orthonorm(Omega, q, opt.Std);
            % Recompute covariance matrix of reduced-form residuals if it is
            % reduced rank.
            if q<ny
                var = opt.Std .^ 2;
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
            opt.Test = join(string(opt.Test), " && ");
            if isempty(opt.Test) && strlength(opt.Test)==0
                utils.error('SVAR:identify', ...
                    ['Cannot run SVAR() with Method=''householder'' and ', ...
                    'empty Test.']);
            end
            if any(opt.NDraw<=0)
                utils.warning('SVAR:identify', ...
                    ['Because NDraw is zero, ', ...
                    'empty SVAR object is returned.']);
            end
            [B0, count] = local_draw(this, opt);
            nv = size(B0, 3);
            A0 = repmat(A0, 1, 1, nv);
            this = alter(this, nv);
    end

    if opt.Std~=1
        B0 = B0 / opt.Std;
    end

    this.A0(:, :, :) = A0;
    this.B0(:, :, :) = B0;
    this.B(:, :, :) = B0;
    this.Rank(:, :) = repmat(q, 1, nv);
    this.Method(:, :) = {method};

    return


    end


    function [BB, count] = local_draw(this, opt)
    %
    % * Rubio-Ramirez J.F., D.Waggoner, T.Zha (2005) Markov-Switching Structural
    % Vector Autoregressions: Theory and Application. FRB Atlanta 2005-27.
    %
    % * Berg T.O. (2010) Exploring the international transmission of U.S. stock
    % price movements. Unpublished manuscript. Munich Personal RePEc Archive
    % 23977, http://mpra.ub.uni-muenchen.de/23977.

    test = opt.Test;
    A = polyn.var2polyn(this.A);
    C = sum(A, 3);
    invC = inv(C);
    ny = size(A, 1);

    [h, isy] = parseTest(this, test);

    P = covfun.orthonorm(this.Omega);
    count = 0;
    maxFound = opt.NDraw;
    maxIter = opt.MaxIter;
    BB = nan(ny, ny, 0);
    SS = nan(ny, ny, h, 0);
    YY = nan(ny, ny, 0);

    % Create command-window progress bar.
    if opt.Progress
        pbar = ProgressBar("[IrisToolbox] @SVAR/identify progress");
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
        local_testAndInclude( );
        nb = size(BB, 3);
        if opt.Progress
            update( pbar, max(count/maxIter, nb/maxFound) );
        end
    end

return


    function local_testAndInclude()
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


function B0 = local_backorder(B0, reorder, backorderResiduals)
    % Put variables (and residuals, if requested) back in order.
    %(
    if isempty(reorder)
        return
    end

    [~, backorder] = sort(reorder);
    if backorderResiduals
        B0 = B0(backorder, backorder, :);
    else
        B0 = B0(backorder, :, :);
    end
    %)
end%


function [A, Omega] = local_reorder(A, Omega, reorder, endogenousNames)
    if ~isempty(reorder)
        if ischar(reorder) || iscellstr(reorder) || isstring(reorder)
            list = textual.stringify(reorder);
            reorder = nan(size(list));
            for i = 1 : numel(list)
                index = find(strcmp(list(i), endogenousNames), 1);
                if ~isempty(index)
                    reorder(i) = index;
                end
            end
            valid = ~isnan(reorder);
            if any(~valid)
                exception.error([
                    "SVAR"
                    "This is not a valid VAR endogenous name: %s"
                ], list(~valid));
            end
        end
        ny = size(A, 1);
        reorder = reshape(reorder, 1, []);
        if any(isnan(reorder)) ...
                || numel(reorder)~=ny ...
                || numel(intersect(1:ny, reorder))~=ny
            utils.error('SVAR:identify', ...
                'Invalid reordering vector.');
        end
        A = A(reorder, reorder, :, :);
        Omega = Omega(reorder, reorder, :);
    end
end%


