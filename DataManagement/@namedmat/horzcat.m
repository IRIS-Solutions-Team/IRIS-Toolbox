function varargout = horzcat(varargin)

for i = 1 : length(varargin)
    if isa(varargin{i}, 'namedmat')
        varargin{i} = double(varargin{i});
    end
end

[varargout{1:nargout}] = horzcat(varargin{:});

end%

