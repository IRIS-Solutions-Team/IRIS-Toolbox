function varargout = fromModel(model, filterRange, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser('@LinearSystem.fromModel');
    addRequired(pp, 'model', @(x) isa(x, 'Model'));
    addRequired(pp, 'filterRange', @DateWrapper.validateProperRangeInput);
    addParameter(pp, 'Override', struct( ), @validate.databank);
    addParameter(pp, 'Multiply', struct( ), @validate.databank);
end
parse(pp, model, filterRange, varargin{:});
opt = pp.Options;

%--------------------------------------------------------------------------

input = struct( );
input.Variant = 1;
input.FilterRange = filterRange;
input.Override = opt.Override;
input.Multiply = opt.Multiply;
input.BreakUnlessTimeVarying = false;

[varargout{1:nargout}] = prepareLinearSystem(model, input);

end%

