%{
% 
% # `eig` ^^(Model)^^
% 
% {== Eigenvalues of model transition matrix ==}
% 
% 
% ## Syntax 
% 
%     [eigenVal, stab] = eig(M)
% 
% ## Input arguments 
% 
%     `M` [ model ]
% > 
% > Model object whose eigenvalues will be returned.
% > 
% 
% ## Output arguments 
% 
% 
%     __`eigenVal`__ [ numeric ]
% > 
% > Array of all eigenvalues associated with the model, i.e. all stable,
% > unit, and unstable roots are included.
% >
% 
%     __`stab`__ [ int8 ] 
% >
% > Classification of each root in the `EigenValues` vector: `0` means a
% > stable root, `1` means a unit root, `2` means an unstable root; `stab` is
% > filled with zeros in models or parameter variants where no solution has
% > been computed.
% >
% 
% 
% ## Options 
% 
% 
% ## Description 
% 
% 
% 
% ## Examples
% 
% 
%}
% --8<--


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

