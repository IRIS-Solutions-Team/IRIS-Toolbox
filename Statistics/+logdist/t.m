function fn = t(mean_, std_, df)
% t  Create function proportional to log of Student T distribution.
%
% Syntax
% =======
%
%     fn = logdist.t(mean, stdev, df)
%
%
% Input arguments
% ================
%
% * `mean` [ numeric ] - Mean of the normal distribution.
%
% * `stdev` [ numeric ] - Stdev of the normal distribution.
%
% * `df` [ integer ] - Number of degrees of freedom. If finite, the
% distribution is Student T; if omitted or `Inf` (default) the distribution
% is Normal.
%
% Multivariate cases are supported. Evaluating multiple vectors as an array
% of column vectors is supported.
%
%
% Output arguments
% =================
%
% * `fn` [ function_handle ] - Function handle returning a value
% proportional to the log of Normal or Student density.
%
%
% Description
% ============
%
% See [help on the logdisk package](logdist/Contents) for details on using
% the function handle `gn`.
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2021 IRIS Solutions Team and Boyan Bejanov.

if nargin<3
    df = Inf;
end

%--------------------------------------------------------------------------

mode = mean_(:);
a = mean_(:);

if numel(mean_)>1
    % Distribution is multivariate
    std_ = logdist.chkStd( std_ );
    b = std_;
    if isinf(gammaln(df))
        fn = logdist.normal(mean_, std_);
    else
        fn = @(x, varargin) fnMultT(x, a, b, mean_, std_, df, mode, varargin{:});
    end
else
    % Distribution is scalar
    b = std_;
    if isinf(gammaln(df))
        fn = logdist.normal(mean_, std_);
    else
        fn = @(x, varargin) fnT(x, a, b, mean_, std_, df, mode, varargin{:});
    end
end
end




function y = fnMultT(x, a, b, mean_, std_, df, mode_, varargin)
k = numel(mean_);
if isempty(varargin)
    y = logMultT( );
    return
end
chi2fh = logdist.chisquare(df);
switch lower(varargin{1})
    case {'rand', 'draw'}
        if numel(varargin)<2
            dim = size(mean_);
        else
            if numel(varargin{2})==1
                dim = [k, varargin{2}];
            else
                dim = varargin{2};
            end
        end
        C = sqrt( df ./ chi2fh([ ], 'draw', dim) );
        R = bsxfun(@times, std_*randn(dim), C);
        y = bsxfun(@plus, mean_, R);    case {'proper', 'pdf'}
        y = exp(logMultT( ));
    case 'info'
        % add this later...
        y = NaN(size(std_));
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
end

return




    function y = logMultT( )
        tpY = false;
        if size(x, 1)~=numel(mean_)
            x = transpose(x);
            tpY = true;
        end
        sX = bsxfun(@minus, x, mean_)' / std_;
        logSqrtDetSig = sum(log(diag(std_)));
        y = ( gammaln(0.5*(df+k)) - gammaln(0.5*df) ...
            - logSqrtDetSig - 0.5*k*log(df*pi) ) ...
            - 0.5*(df+k)*log1p( ...
            sum(sX.^2, 2)'/df...
            );
        if tpY
            y = y';
        end
    end
end




function y = fnT(x, a, b, mean_, std_, df, mode_, varargin)
if isempty(varargin)
    sX = bsxfun(@minus, x, mean_).' / std_;
    y = -0.5*(df+1)*log1p( sX.^2/df );
    return
end
chi2fh = logdist.chisquare(df);
switch lower(varargin{1})
    case {'rand', 'draw'}
        if numel(varargin)<2
            dim = size(mean_);
        else
            dim = varargin{2:end};
        end
        C = sqrt( df ./ chi2fh([ ], 'draw', dim) );
        R = bsxfun(@times, std_*randn(dim), C);
        y = bsxfun(@plus, mean_, R);
    case {'icdf', 'quantile'}
        y = NaN(size(x));
        y( x<eps ) = -Inf;
        y( 1-x<eps ) = Inf;
        ind = ( x>=eps ) & ( (1-x)>=eps );
        pos = ind & ( x>0.5 );
        x( ind ) = min( x(ind), 1-x(ind) );
        % this part for accuracy
        low = ind & ( x<=0.25 );
        high = ind & ( x>0.25 );
        qs = betaincinv( 2*x(low), 0.5*df, 0.5 );
        y( low ) = -sqrt( df*(1./qs-1) );
        qs = betaincinv( 2*x(high), 0.5, 0.5*df, 'upper' );
        y( high ) = -sqrt( df./(1./qs-1) );
        y( pos ) = -y( pos );
        y = mean_ + y*std_;
    case {'proper', 'pdf'}
        sX = bsxfun(@minus, x, mean_).' / std_;
        y = ( gammaln(0.5*(df+1)) - gammaln(0.5*df) - log(sqrt(df*pi)*std_) ) ...
            - 0.5*(df+1)*log1p( sX.^2/df );
        y = exp(y);
    case 'info'
        % add this later...
        y = NaN(size(x));
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
end
end
