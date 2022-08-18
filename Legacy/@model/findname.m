function varargout = findname(this, varargin)

if nargin<2
    return
end

numOfQueries = numel(varargin);
[~, varargout{1:numOfQueries}] = find(this, 'qty', varargin{:});

end
