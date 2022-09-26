%{
% 
% # `blazer` ^^(Model)^^
% 
% {== Analyze sequential block structure of steady equations ==}
% 
% 
% ## Syntax
% 
%     [nameBlk, eqtnBlk, blkType, blazerObj] = blazer(model, ...)
% 
% 
% ## Input arguments 
% 
% __`model`__ [ Model ]
% > 
% > Model object
% > 
% 
% ## Output arguments 
% 
% __`nameBlk`__ [ cell ]
% > 
% > Lists of variables that each individual block will be solved for; the
% > `nameBlk{i}.Level` element is a string array with the names of the
% > variables whose levels will be solved for in the i-th block; the
% > `nameBlk{i}.Change` element is a string array with the names of the
% > variables whose changes (differences or rates of growth) will be solved
% > for in the i-th block.
% > 
% > 
% 
% __`eqtnBlk`__ [ cell ] 
% > 
% > List of equations in each block.
% > 
% > 
% 
% __`blkType`__ [ solver.block.Type ] 
% > 
% > Type of each block: `SOLVE` or `ASSIGN`.
% > 
% > 
% 
% __`blazerObj`__ [ blazer.Blazer ]
% > 
% >     Blazer object.
% > 
% 
% ## Options 
% 
% __`Endogenize={ }`__ [ cellstr | char | string | empty ]
% > 
% >     List of parameters that will be endogenized in steady equations.
% > 
% > 
% 
% __`Exogenize={ }`__ [ cellstr | char | empty | string ] 
% > 
% >     List of transition or measurement variables that will be exogenized
% >     in steady equations.
% > 
% > 
% 
% __`Kind='Steady'`__ [ `'Current'` | `'Stacked'` | `'Steady'` ]
% > 
% >     The method of sequential block analysis that will be performed.
% > 
% 
% 
% ## Description 
% 
% 
% Three ways the sequential block analysis can be performed:
% 
% *  `'Steady'` 
% Investigate steady-state equations, considering lags and
% leads to be the same entity as the respective current dated variable.
% 
% *  `'Current'` 
% Investigate the current dated variables in dynamic
% equations, taking lags and leads as given.
% 
% *  `'Stacked'` 
% Investigate a whole structure of time-stacked equations
% (not available yet).
% 
% 
% ### Reordering Algorithm
% 
% 
% The reordering algorithm first identifies equations with a single
% variable in each, and variables occurring in a single equation each, and
% then uses a combination of column and row approximate minimum degree
% permutations (`colamd`) followed by a Dulmage-Mendelsohn permutation
% (`dmperm`).
% 
% 
% ### Output Returned from Blazer
% 
% 
% The output arguments `NameBlk` and `EqtnBlk` are 1-by-N cell arrays,
% where N is the number of blocks, and each cell is a 1-by-Kn cell array of
% strings, where Kn is the number of variables and equations in block N.
% 
% 
% ## Examples
% 
%}
% --8<--


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

