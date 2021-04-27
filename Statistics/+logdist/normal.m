function fn = normal(mean_, std_, w_)
% normal  Create function proportional to log of Normal distribution.
%
% Syntax
% =======
%
%     fn = logdist.normal(mean, stdev, w)
%
%
% Input arguments
% ================
%
% * `mean_` [ numeric ] - Mean of the normal distribution.
%
% * `stdev` [ numeric ] - Std dev of the normal distribution.
%
% * `w` [ numeric ] - Optional input containing mixture weights.
%
% Multivariate cases are supported. Evaluating multiple vectors as an array
% of column vectors is supported.
%
% If the mean and standard deviation are cell arrays then the distribution
% will be a mixture of normals. In this case the third argument is the
% vector of mixture weights.
%
%
% Output arguments
% =================
%
% * `fn` [ function_handle ] - Function handle returning a value
% proportional to the log of Normal density.
%
%
% Description
% ============
%
% See [help on the logdisk package](logdist/Contents) for details on using
% the function handle `F`.
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2021 IRIS Solutions Team and Boyan Bejanov.

%--------------------------------------------------------------------------

if iscell( mean_ )
    % Distribution is a normal mixture
    Weight = w_ / sum(w_) ;
    K = numel( mean_{1} ) ;
    Nmix = numel( mean_ ) ;
    if K > 1
        for d = 1:Nmix
            assert( all( size(std_{d}) == numel(mean_{d}) ), ...
                'Mean and covariance matrix dimensions must be consistent.' ) ;
            assert( all( size(mean_{d}) == size(mean_{1}) ), ...
                'Mixture dimensions must be consistent.' ) ;
            std_{d} = logdist.chkStd( std_{d} ) ;
        end
    end
    a = zeros(K, 1) ;
    for d = 1:Nmix
        a = a + Weight(d)*mean_{d} ;
    end
    fn = @(x, varargin) fnMultNormalMixture(x, a, mean_, std_, Weight, varargin{:}) ;
else
    % Distribution is normal
    mode_ = mean_(:) ;
    a = mean_(:) ;
    
    if numel(mean_) > 1
        % Distribution is multivariate
        std_ = logdist.chkStd( std_ ) ;
        b = std_ ;
        
        fn = @(x, varargin) fnMultNormal(x, a, b, mean_, std_, mode_, varargin{:}) ;
    else
        % Distribution is scalar
        b = std_ ;
        fn = @(x, varargin) fnNormal(x, a, b, mean_, std_, mode_, varargin{:}) ;
    end
end

end




function y = fnMultNormalMixture(x, a, mean_, std_, weight, varargin)
Nmix = numel(mean_) ;
K = numel(mean_{1}) ;

if isempty(varargin)
    y = log(mixturePdf( )) ;
    return
end

switch lower(varargin{1})
    case {'proper', 'pdf'}
        y = mixturePdf( ) ;
    case {'rand', 'draw'}
        if numel(varargin)<2
            NDraw = 1 ;
        else
            NDraw = varargin{2} ;
        end
        y = NaN(K, NDraw) ;
        bin = multinomialRand( NDraw, weight ) ;
        for c = 1:Nmix
            ind = ( bin == c ) ;
            NC = sum( ind ) ;
            if NC>0
                y(:, ind) = bsxfun( @plus, mean_{c}, std_{c}*randn(K, NC) ) ;
            end
        end
    case 'name'
        y = 'normal' ;
    case 'mean'
        y = mean_ ;
    case {'sigma', 'sgm', 'std'}
        y = std_ ;
    case {'a', 'location'}
        y = a;
    case {'b', 'scale'}
        y = B;
end

return




    function bin = multinomialRand(NDraw, Prob)
        CS = cumsum(Prob(:).');
        bin = 1+sum( bsxfun(@gt, rand(NDraw, 1), CS), 2);
    end




    function Y = mixturePdf( )
        [N1, N2] = size(x) ;
        Y = zeros(1, N2) ;
        assert( N1 == K, 'Input must be a column vector.' ) ;
        for m = 1:Nmix
            Y = bsxfun(@plus, Y, ...
                weight(m)*exp(logMultNormalPdf(x, mean_{m}, std_{m}))...
                ) ;
        end
    end 
end




function y = logMultNormalPdf(X, Mu, Std)
K = numel(Mu) ;
sX = bsxfun(@minus, X, Mu)' / Std ;
logSqrtDetSig = sum(log(diag(Std))) ;
y = -0.5*K*log(2*pi) - logSqrtDetSig - 0.5*sum(sX.^2, 2)' ;
end




function y = fnNormal(x, a, b, mean_, std_, mode_, varargin)
if isempty(varargin)
    y = -0.5 * ((x - mean_)./std_).^2;
    return
end
switch lower(varargin{1})
    case {'proper', 'pdf'}
        y = 1/(std_*sqrt(2*pi)) .* exp(-(x-mean_).^2/(2*std_^2));
    case 'info'
        y = 1/(std_^2)*ones(size(x));
    case {'a', 'location'}
        y = a;
    case {'b', 'scale'}
        y = b;
    case 'mean'
        y = mean_;
    case {'sigma', 'sgm', 'std'}
        y = std_;
    case 'mode'
        y = mode_;
    case 'name'
        y = 'normal';
    case {'rand', 'draw'}
        y = mean_ + std_*randn(varargin{2:end});
    case 'lower'
        y = -Inf;
    case 'upper'
        y = Inf;
end
end




function y = fnMultNormal(x, a, b, mean_, std_, mode_, varargin)
K = numel(mean_) ;
if isempty(varargin)
    y = logMultNormalPdf(x, mean_, std_) ;
    return
end
switch lower(varargin{1})
    case {'proper', 'pdf'}
        y = exp(logMultNormalPdf(x, mean_, std_)) ;
    case 'info'
        y = eye(size(std_)) / ( std_.'*std_ ) ;
    case {'a', 'location'}
        y = a ;
    case {'b', 'scale'}
        y = b ;
    case 'mean'
        y = mean_ ;
    case {'sigma', 'sgm', 'std'}
        y = std_ ;
    case 'mode'
        y = mode_ ;
    case 'name'
        y = 'normal';
    case {'rand', 'draw'}
        if numel(varargin)<2
            dim = size(mean_) ;
        else
            if numel(varargin{2})==1
                dim = [K, varargin{2}] ;
            else
                dim = varargin{2} ;
            end
        end
        y = bsxfun(@plus, mean_, std_*randn(dim)) ;
end
end

