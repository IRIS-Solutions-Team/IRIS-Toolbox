function varargout = eig(this, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser('Model/eig');
    addRequired(pp, 'model', @(x) isa(x, 'model'));
    addOptional(pp, 'variants', Inf, @(x) isequal(x, @all) || isequal(x, Inf) || strcmp(x, ':') || isnumeric(x) || islogical(x));

    addParameter(pp, 'SystemProperty', false, @(x) isequal(x, false) || validate.list(x));
    addParameter(pp, 'Stability', [0, 1, 2], @(x) isnumeric(x) && all(ismember(x, [0, 1, 2])));
end
parse(pp, this, varargin{:});
variantsRequested = pp.Results.variants;
opt = pp.Options;

if isequal(variantsRequested, Inf) || isequal(variantsRequested, @all)
    variantsRequested = ':';
end

%--------------------------------------------------------------------------

varargout = { 
    this.Variant.EigenValues(:, :, variantsRequested) ...
    , this.Variant.EigenStability(:, :, variantsRequested)
};

end%

