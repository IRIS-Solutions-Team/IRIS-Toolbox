function varargout = findeqtn(this, varargin)

if nargin<2
    return
end

numOfQueries = numel(varargin);
[~, varargout{1:numOfQueries} ] = find(this, 'eqn', varargin{:});

end
