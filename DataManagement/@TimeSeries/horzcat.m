function this = horzcat(varargin)

if numel(varargin)==1
    this = varargin{1};
    return
end
this = cat(2, varargin{:});

end

