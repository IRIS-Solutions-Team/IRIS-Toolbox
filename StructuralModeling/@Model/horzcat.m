function this = horzcat(this, varargin)

if nargin==1
    return
end

for i = 1 : numel(varargin)
    nv = length(this);
    nvToAdd = length(varargin{i});
    pos = nv + (1 : nvToAdd);
    assert( ...
        isa(varargin{i}, 'model') && testCompatible(this, varargin{i}), ...
        'model:horzcat', ...
        'Model objects A and B are not compatible in horizontal concatenation [A, B].' ...
    );
    this.Variant = subscripted(this.Variant, pos, varargin{i}.Variant, ':');
end

end%

