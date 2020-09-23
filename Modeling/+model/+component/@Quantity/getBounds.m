function bounds = getBounds(this, varargin)

try
    finiteOnly = startsWith(varargin{1}, "finite", "ignoreCase", true);
catch
    finiteOnly = false;
end

bounds = struct( );
names = reshape(string(this.Name), 1, [ ]);
for i = 1 : numel(names)
    if ~finiteOnly || ~all(isinf(this.Bounds(:, i)))
        bounds.(names(i)) = this.Bounds(:, i);
    end
end

end%

