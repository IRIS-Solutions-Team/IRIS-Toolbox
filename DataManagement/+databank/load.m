function outputDb = load(fileName, varargin)

if numel(varargin)==1 && iscellstr(varargin{1})
    varargin = varargin{1};
end

outputDb = load(fileName, varargin{:});

end%

