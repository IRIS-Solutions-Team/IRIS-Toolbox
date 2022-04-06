function f = fields(s, varargin)

if isempty(varargin)
    varargin = {1, []};
end
f = reshape(string(fieldnames(s)), varargin{:});

end%
