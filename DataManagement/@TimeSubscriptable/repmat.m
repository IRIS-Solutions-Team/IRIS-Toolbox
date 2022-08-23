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
ip = inputParser();
ip.addRequired('X', @(x) isa(x, 'Series'));
ip.addRequired('RepK', @(x) ~isempty(x) && all(cellfun(isnumericscalar,x)) && isequal(x{1},1));
ip.parse(this, varargin);

varargin{1} = 1;
this.Data = repmat(this.Data, varargin{:});
this.Comment = repmat(this.Comment, varargin{:});

end%

