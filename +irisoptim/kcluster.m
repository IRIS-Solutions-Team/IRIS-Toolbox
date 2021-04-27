function [M, Sig, W, fh] = kcluster(Sample, varargin)
% kcluster  Fits multivariate mixture of normals to a sample using the k-harmonic means algorithm. 
%
%
% Syntax
% =======
%
%     F = irisoptim.kcluster(Sample,...)
%
%
% Input arguments
% =================
%
% * `Sample` [ numeric ]
%
%
% Output arguments
% ================
%
% * `Mu` [ cell ] - Cell array of mixture means.
%
% * `Sig` [ cell ] - Cell array of mixture covariance matrices.
%
% * `W` [ numeric ] - Vector of mixture weights.
%
% * `fh` [ function_handle ] - Function handle to the estimated
% distribution function in the `logdist` package.
%
%
% Options
% ========
%
% * `'display='` [ true | *`false`* ] - Display command window output.
%
% * `'k='` [ integer | *`4`* ] - By default `k` determines the maximum
% number of clusters, but the option `'select='` can be set to `'fixed'` so
% that this option determines `k` exactly.
%
% * `'select='` [ *`bic`* | `fixed` ] - Fix the number of clusters or
% select using the Bayesian Information Criterion.
%
% * `'tol='` [ numeric | *`1e-6`* ] - Critical value which determines
% termination of the iterative refinement algorithm.
%
% * `'maxIt='` [ integer | *`500`* ] - Maximum number of refinement
% iterations.
%
%
% Description
% ============
%
% Uses k-harmonic means clustering to estimate a multivariate distribution
% as a mixture of normals.
%
%
% References
% ===========
%
% * Zhang, Hsu and Dayal (1999) "K-Harmonic Means - A Data Clustering
% Algorithm."
%
% * Hamerly and Elkan (2002) "Alternatives to the k-means algorithm that
% find better clusterings."
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2021 IRIS Solutions Team.

pp = inputParser( );
pp.addRequired('Sample', @isnumeric );
pp.parse( Sample );

% Parse options.
opt = passvalopt('dest.kcluster',varargin{:});

% Constants
[D,N] = size(Sample) ;
if D>N
    Sample = Sample' ;
    [N,D] = deal(D,N) ;
end

% display
if opt.display
    fprintf(1,'Clusters     BIC      log(L)      Penalty \n') ;
end

if strcmpi(opt.selectk,'fixed')
    [M, Sig, W, kLik, kBic, pen] = xxKcluster( Sample, opt.k ) ;
    if opt.display
        fprintf(1,'%2.0g          %+4.2f      %+4.2f      %+4.2f \n',...
            opt.k, kBic, kLik, pen) ;
    end
else
    tol = sqrt(eps) ;
    stor = struct( ) ;
    storBic = NaN(opt.k,1) ;
    for k=1:opt.k
        % try k-means cluster
        [kM, kSig, kW, kLik, kBic, pen] = xxKcluster( Sample, k ) ;
        nm = sprintf('k%g',k) ;
        stor.(nm).M = kM ;
        stor.(nm).Sig = kSig ;
        stor.(nm).W = kW ;
        stor.(nm).Lik = kLik ;
        storBic(k) = kBic ;
        stor.(nm).pen = pen ;
        
        % check for repeated clusters
        repeated = false;
        for ik=1:k
            if repeated, break; end
            for jj=ik+1:k
                repeated = sum( (kM{ik}-kM{jj}).^2 ) < tol ;
                if repeated, break; end
            end
        end
        if repeated, continue; end
        
        % display
        if opt.display
            fprintf(1,'%2.0g          %+4.2f      %+4.2f      %+4.2f \n',...
                k, kBic, kLik, pen) ;
        end
    end %for
    
    [~,bestK] = min(storBic) ;
    nm = sprintf('k%g',bestK) ;
    M = stor.(nm).M ;
    Sig = stor.(nm).Sig ;
    W = stor.(nm).W ;
    
end %if
if nargout>3
    % function handle to estimated distribution
    fh = logdist.normal(M,Sig,W) ;
end

    function [M, Sig, W, lLik, BIC, penalty, ik] = xxKcluster(thisSample, thisK)
        
        % pick k points from the bunch at random (Forgy)
        M = thisSample(:,randperm(N,thisK));
        
        % refine to find means
        [M, W, p] = refineCenters(thisK, M);
        
        % Estimate covariance matrices via EM
        Sig = cell(1,thisK);
        Lik = 0 ;
        for ik = 1:thisK
            thisCov = zeros(D,D) ;
            mkSample = bsxfun(@minus, thisSample, M{ik}) ;
            kSumP = sum(p(ik,:)) ;
            for iobs = 1:N
                thisCov = thisCov + p(ik,iobs)*( mkSample(:,iobs)*mkSample(:,iobs)' ) / kSumP ;
            end
            Sig{ik} = chol( thisCov ) ;
            Lik = Lik + W(ik)*exp( -0.5*sum( ( Sig{ik}' \ mkSample ).^2, 1 ) ) / ( sqrt(2*pi).^D * prod(diag(Sig{ik})) ) ;
            lLik = sum(log(Lik),2) ;
        end
        
        % compute BIC
        penalty = thisK*log(N) ;
        BIC = -2*lLik + penalty ;
        
        %************* nested functions ******************%
        
        function [M,W,p,ik,iobs] = refineCenters(thisK, M)
            % Iterative refinement of k harmonic means using the algorithm
            % described in Zhang, Hsu and Dayal (1999).
            p = NaN(thisK,N) ;
            pp = p ;
            it = 0 ;
            crit = Inf ;
            M0 = M ;
            while it<opt.maxit && crit>opt.tol
                if ~opt.vectorized
                    % keep this just because it is significantly easier to
                    % debug
                    for iobs = 1:N
                        [qVec] = qCalc( thisSample(:,iobs), M, thisK ) ;
                        p(:,iobs) = qVec ./ sum(qVec) ;
                    end
                else
                    p = pCalcVec( thisSample, M, thisK ) ;
                end
                for ik = 1:thisK
                    M(:,ik) = sum( bsxfun(@times, thisSample, p(ik,:) ), 2 ) / sum( p(ik,:) ) ;
                end
                crit = norm(M-M0) ;
                M0 = M ;
            end
            if it==opt.maxit
                utils.warning('dest:kcluster',['Iterative refinement of k-harmonic means' ...
                    'failed to converge to the tolerance %g within %g iterations.'],...
                    opt.tol,opt.maxit) ;
            end
            W = sum( p, 2 ) ;
            W = W ./ sum(W) ;
            M = num2cell( M, 1 ) ;
            
            function [q,r,d,ik] = qCalc( X, M, thisK ) %#ok<*STOUT>
                d = max( colDist( X, M' ), 1e-14 ) ;
                [dMin,minInd] = min(d) ;
                r = ( dMin ./ d ).^2 ;
                lInd = true(thisK,1) ;
                lInd(minInd) = false ;
                q = r.^3*dMin / (1 + sum(r(lInd)))^2 ;
            end
            
            function [p,ik] = pCalcVec( X, M, thisK )
                d = NaN(thisK,N) ;
                for ik = 1:thisK
                    dt = bsxfun(@minus, X, M(:,ik)) ;
                    dt = bsxfun(@power, dt, 2) ;
                    dt = sqrt(sum(dt,1)) ;
                    d(ik,:) = dt ;
                end
                d = bsxfun(@max, d, 1e-14) ;
                ds = sort(d) ;
                % r = ( dMin ./ d ).^2 ;
                r = bsxfun(@rdivide, ds(1,:), d) ;
                r = bsxfun(@power, r, 2) ;
                % q = r.^3*dMin / (1 + sum(r(lInd)))^2 ;
                r = bsxfun(@power, r, 3) ;
                r = bsxfun(@times, r, ds(1,:)) ;
                de = 1+sum(ds(2:end,:),1) ;
                de = bsxfun(@power, de, 2) ;
                q = bsxfun(@rdivide, r, de) ;
                % p = q ./ sum(q) ;
                qs = sum(q,1) ;
                p = bsxfun(@rdivide, q, qs) ;
            end
            
            function d = colDist( A, b )
                C = bsxfun(@minus, A, b) ;
                d = sqrt( sum( C.*C, 2 ) ) ;
            end
            
        end %refineCenters
    end %xxKcluster

end % kcluster( ).





