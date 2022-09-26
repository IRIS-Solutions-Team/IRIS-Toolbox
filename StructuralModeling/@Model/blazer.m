function [nameBlk, eqtnBlk, blkType, blazer] = blazer(this, varargin)

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('model.blazer');
    pp.KeepUnmatched = true;

    addRequired(pp, 'model', @(x) isa(x, 'model'));
    addParameter(pp, 'Kind', 'Steady', @(x) any(startsWith(x, ["Steady", "Stacked", "Period"], "ignoreCase", true)));

    pp.addParameter({'Blocks', 'Block'}, true, @(x) isequal(x, true) || isequal(x, false));
    pp.addParameter('Growth', @auto, @(x) isequal(x, @auto) || isequal(x, true) || isequal(x, false));
    pp.addParameter('Log', [ ], @(x) isempty(x) || ischar(x) || iscellstr(x) || isequal(x, @all));
    pp.addParameter('Unlog', [ ], @(x) isempty(x) || ischar(x) || iscellstr(x) || isequal(x, @all));
    pp.addParameter('SaveAs', "", @(x) isempty(x) || ischar(x) || (isstring(x) && isscalar(x)));
    pp.addParameter("SuccessOnly", false, @validate.logicalScalar);
    pp.addSwapFixOptions( );
end
opt = parse(pp, this, varargin{:});
%)

%--------------------------------------------------------------------------

nameBlk = cell(1, 0); %#ok<PREALL>
eqtnBlk = cell(1, 0); %#ok<PREALL>

%
% Create a blazer object of the right type
%
if startsWith(opt.Kind, "steady", "ignoreCase", true)
    blazer = solver.blazer.Steady.forModel(this, opt);
elseif startsWith(opt.Kind, "stacked", "ignoreCase", true)
    blazer = solver.blazer.Stacked.forModel(this, opt);
elseif startsWith(opt.Kind, "period", "ignoreCase", true)
    blazer = solver.blazer.Period.forModel(this, opt);
end

if ~isempty(opt.SaveAs)
    blazer.SaveAs = string(opt.SaveAs);
end

%
% Split equations into sequential blocks and prepare blocks; do not prepare
% solver options and Jacobian information; save to opt.SaveAs file if
% requested
%
run(blazer);

[eqtnBlk, nameBlk, blkType] = locallyGetHuman(blazer, opt.Kind);

end%


%
% Local Functions
%


function [blkEqnHuman, blkQtyHuman, blkType] = locallyGetHuman(blazer, kind)
    numBlocks = numel(blazer.Blocks);
    blkEqnHuman = cell(1, numBlocks);
    blkQtyHuman = cell(1, numBlocks);
    blkType = repmat(solver.block.Type.SOLVE, 1, numBlocks);
    for i = 1 : numBlocks
        block__ = blazer.Blocks{i};
        blkEqnHuman{i} = reshape(string(blazer.Model.Equation.Input(block__.PtrEquations)), [ ], 1);
        if startsWith(kind, "steady", "ignoreCase", true)
            [ptrLevel__, ptrChange__] = iris.utils.splitRealImag(block__.PtrQuantities);
            blkQtyHuman{i} = struct( ...
                'Level', reshape(string(blazer.Model.Quantity.Name(ptrLevel__)), 1, [ ]), ...
                'Change', reshape(string(blazer.Model.Quantity.Name(ptrChange__)), 1, [ ]) ...
            );
        else
            blkQtyHuman{i} = reshape(string(blazer.Model.Quantity.Name(block__.PtrQuantities)), 1, [ ]);
        end
        blkType(i) = block__.Type;
    end
end%

