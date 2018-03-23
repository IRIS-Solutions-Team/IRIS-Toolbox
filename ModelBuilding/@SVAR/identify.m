function [this, data, B, count] = identify(this, data, opt)
% identify  Convert reduced-form VAR to structural VAR
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

%--------------------------------------------------------------------------

ny = size(this.A, 1);
nv = size(this.A, 3);

A = polyn.var2polyn(this.A);
Omg = this.Omega;

% Std dev of structural residuals requested by the user.
this.Std = opt.std(1, ones(1, nv));

this.Method = cell(1, nv);
B = zeros(ny, ny, nv);
q = Inf;

count = 1;
switch lower(opt.method)
    case 'chol'
        this.Method(:) = {'Cholesky'};
        reorder( );
        for v = 1 : nv
            B(:, :, v) = chol(Omg(:, :, v)).';
        end
        backorder( );
    case 'qr'
        this.Method(:) = {'QR'};
        reorder( );
        C = sum(A, 3);
        for v = 1 : nv
            B0 = transpose(chol(Omg(:, :, v)));
            if rank(C(:, :, 1, v))==ny
                Q = qr(transpose(C(:, :, 1, v)\B0));
            else
                Q = qr(transpose(pinv(C(:, :, 1, v))*B0));
            end
            B(:, :, v) = B0*Q;
        end
        backorder( );
    case 'svd'
        this.Method(:) = {'SVD'};
        q = opt.rank;
        B = covfun.orthonorm(Omg, q, opt.std);
        % Recompute covariance matrix of reduced-form residuals if it is
        % reduced rank.
        if q<ny
            var = opt.std .^ 2;
            for v = 1 : nv
                this.Omega(:, :, v) = ...
                    B(:, 1:q, v)*B(:, 1:q, v)'*var;
            end
        end
    case 'householder'
        this.Method(:) = {'Householder'};
        % Use Householder transformations to draw random SVARs. Test each SVAR
        % using teh `'test='` string to decide whether to keep it or discard.
        if nv>1
            utils.error('SVAR:identify', ...
                ['Cannot run SVAR( ) with ''method=householder'' on ', ...
                'a VAR object with multiple parameterisation.']);
        end
        if isempty(opt.test)
            utils.error('SVAR:identify', ...
                ['Cannot run SVAR( ) with ''method=householder'' and ', ...
                'empty ''test=''.']);
        end
        if any(opt.ndraw <= 0)
            utils.warning('SVAR:identify', ...
                ['Because ''ndraw='' is zero, ', ...
                'empty SVAR object is returned.']);
        end
        [B, count] = draw(this, opt);
        nv = size(B, 3);
        this = alter(this, nv);
end

if opt.std ~= 1
    B = B / opt.std;
end

this.B(:, :, :) = B;
this.Rank = q;

return


    function reorder( )
        if ~isempty(opt.reorder)
            if iscellstr(opt.reorder)
                list = opt.reorder;
                nList = length(list);
                valid = true(1, nList);
                opt.reorder = nan(1, nList);
                for i = 1 : nList
                    pos = strcmp(this.NamesEndogenous, list{i});
                    valid(i) = any(pos);
                    if valid(i);
                        opt.reorder(i) = find(pos);
                    end
                end
                if any(~valid)
                    utils.error('SVAR:identify', ...
                        ['This variable name does not exist ', ...
                        'in the VAR object: ''%s''.'], ...
                        list{~valid});
                end
            end
            opt.reorder = opt.reorder(:)';
            if any(isnan(opt.reorder)) ...
                    || length(opt.reorder) ~= ny ...
                    || length(intersect(1:ny, opt.reorder)) ~= ny
                utils.error('SVAR:identify', ...
                    'Invalid reordering vector.');
            end
            A = A(opt.reorder, opt.reorder, :, :);
            Omg = Omg(opt.reorder, opt.reorder, :);
        end
    end


    function backorder( )
        % Put variables (and residuals, if requested) back in order.
        if ~isempty(opt.reorder)
            [~, backOrder] = sort(opt.reorder);
            if opt.backorderresiduals
                B = B(backOrder, backOrder, :);
            else
                B = B(backOrder, :, :);
            end
        end
    end 

end


function [BB, Count] = draw(This, Opt)
%
% * Rubio-Ramirez J.F., D.Waggoner, T.Zha (2005) Markov-Switching Structural
% Vector Autoregressions: Theory and Application. FRB Atlanta 2005-27.
%
% * Berg T.O. (2010) Exploring the international transmission of U.S. stock
% price movements. Unpublished manuscript. Munich Personal RePEc Archive
% 23977, http://mpra.ub.uni-muenchen.de/23977.

test = Opt.test;
A = polyn.var2polyn(This.A);
C = sum(A, 3);
Ci = inv(C);
ny = size(A, 1);

[h, isy] = myparsetest(This, test);

P = covfun.orthonorm(This.Omega);
Count = 0;
maxFound = Opt.ndraw;
maxIter = Opt.MaxIter;
BB = nan(ny, ny, 0);
SS = nan(ny, ny, h, 0);
YY = nan(ny, ny, 0);

% Create command-window progress bar.
if Opt.progress
    pbar = ProgressBar('IRIS VAR.SVAR progress');
end

nb = 0;
while Count<maxIter && nb<maxFound
    Count = Count + 1;
    % Candidate rotation. Note that we need to call `qr` with two
    % output arguments to get the unitary matrix `Q`.
    [Q, ~] = qr(randn(ny));
    B = P*Q;
    % Compute impulse responses T = 1 .. h.
    if h>0
        S = timedom.var2vma(This.A, B, h);
    else
        S = zeros(ny, ny, 0);
    end
    % Compute asymptotic cum responses.
    if isy
        Y = Ci*B; %#ok<MINV>
    end
    % Test impulse responses, and include successful candidates.
    testAndInclude( );
    nb = size(BB, 3);
    if Opt.progress
        update( pbar, max(Count/maxIter, nb/maxFound) );
    end
end

return


    function testAndInclude( )
        try
            pass = isequal(eval(test), true);
            if pass
                BB(:, :, end+1) = B;
                SS(:, :, :, end+1) = S; %#ok<SETNU>
                if isy
                    YY(:, :, end+1) = Y; %#ok<SETNU>
                end
            else
                % Test minus the structure.
                B = -B;
                S = -S;
                if isy
                    Y = -Y;
                end
                pass = isequal(eval(test), true);
                if pass
                    BB(:, :, end+1) = B;
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
    end 
end 
