function varargout = plot(varargin)

% Permute the namedmat input arguments.
index = cellfun(@(x) isa(x, 'namedmat'), varargin);
for i = find(index)
    varargin{i} = permute(varargin{i}, [3, 1, 2, 4]);
    varargin{i} = double(varargin{i});
    varargin{i} = varargin{i}(:, :);
end

% Remove equal signs from options, which will be passed to the standard
% plot function.
last = find(index, 1, 'last');
varargin(last+1:2:end) = strrep(varargin(last+1:2:end), '=', '');

[varargout{1:nargout}] = plot(varargin{:});

end%

