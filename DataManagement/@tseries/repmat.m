function this = repmat(this, varargin)
% repmat  Repeat copies of time series data.
%
%
% Syntax
% =======
%
%     X = repmat(X, Rep1, Rep2,...)
%
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Input time series.
%
% * `Rep1`, `Rep2`, ... [ numeric ] - List of scalars that describe how
% copies of `X` data are arranged in each dimension.
%
%
% Output arguments
% =================
%
% * `X` [ tseries ] - Output time series.
%
%
% Description
% ============
%
% See help on built-in `bsxfun` for more help.
%
%
% Example
% ========
%

isnumericscalar = @(x) isnumeric(x) && isscalar(x);
pp = inputParser( );
pp.addRequired('X', @(x) isa(x, 'tseries'));
pp.addRequired('RepK', ...
    @(x) ~isempty(x) && all(cellfun(isnumericscalar,x)) && isequal(x{1},1));
pp.parse(this,varargin);

%--------------------------------------------------------------------------

if varargin{1}(1)~=1
    utils.error('tseries:repmat', ...
        'Time series cannot be repeated in first dimension.');
end

this.data = repmat(this.data, varargin{:});
this.Comment = repmat(this.Comment, varargin{:});

end
