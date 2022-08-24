function bounds = getBounds(this, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser();
    addParameter(pp, "FiniteOnly", false, @validate.logicalScalar);
end
opt = parse(pp, varargin{:});

    bounds = struct( );
    names = reshape(string(this.Name), 1, [ ]);
    for i = 1 : numel(names)
        if ~opt.FiniteOnly || ~all(isinf(this.Bounds(:, i)))
            bounds.(names(i)) = this.Bounds(:, i);
        end
    end

end%

