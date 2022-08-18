function this = repmat(this, varargin)

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
