function this = repmat(this, varargin)

isnumericscalar = @(x) isnumeric(x) && isscalar(x);
ip = inputParser();
ip.addRequired('X', @(x) isa(x, 'Series'));
ip.addRequired('RepK', @(x) ~isempty(x) && all(cellfun(isnumericscalar,x)) && isequal(x{1},1));
ip.parse(this, varargin);

varargin{1} = 1;
this.Data = repmat(this.Data, varargin{:});
this.Comment = repmat(this.Comment, varargin{:});

end%

