function [nameBlk, eqtnBlk, blkType, blz] = blazer(this, varargin)
% blazer  Reorder dynamic or steady equations and variables into sequential block structure.
%
% __Syntax__
%
%     [NameBlk, EqtnBlk, BlkType] = blazer(M, ...)
%
%
% __Input Arguments__
%
% * `M` [ model ] - Model object.
%
%
% __Output Arguments__
%
% * `M` [ model ] - Model object with variables and steady-state equations
% regrouped to create sequential block structure.
%
% * `NameBlk` [ cell ] - Cell of cellstr with variable names in each block.
%
% * `EqtnBlk` [ cell ] - Cell of cellstr with equations in each block.
%
% * `BlkType` [ solver.block.Type ] - Type of each equation block: `SOLVE` or
% `ASSIGN`.
%
%
% __Options__
%
% * `'Endogenize='` [ cellstr | char ] - List of parameters that will be
% endogenized in steady equations.
%
% * `'Exogenize='` [ cellstr | char ] - List of transition or measurement
% variables that will be exogenized in steady equations.
%
% * `'Kind='` [ `'Current'` | `'Stacked'` | *`'Steady'`* ] - The kind of
% sequential block analysis that will be performed.
%
%
% __Description__
%
% Three kinds of sequential block analysis can be performed:
%
% * `'Steady'` - Investigate steady-state equations, considering lags and
% leads to be the same entity as the respective current dated variable.
%
% * `'Current'` - Investigate the current dated variables in dynamic
% equations, taking lags and leads as give.
%
% * `'Stacked'` - Investigate a whole structure of time-stacked equations
% (not available yet).
%
%
% _Reordering Algorithm_
%
% The reordering algorithm first identifies equations with a single
% variable in each, and variables occurring in a single equation each, and
% then uses a combination of column and row approximate minimum degree
% permutations (`colamd`) followed by a Dulmage-Mendelsohn permutation
% (`dmperm`).
%
%
% _Output Returned from Blazer_
%
% The output arguments `NameBlk` and `EqtnBlk` are 1-by-N cell arrays, 
% where N is the number of blocks, and each cell is a 1-by-Kn cell array of
% strings, where Kn is the number of variables and equations in block N.
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

persistent parser
if isempty(parser)
    parser = extend.InputParser('model/blazer');
    parser.KeepUnmatched = true;
    parser.addRequired('Model', @(x) isa(x, 'model'));
    parser.addParameter('Kind', 'Steady', @(x) ischar(x) && any(strcmpi(x, {'Steady', 'Current', 'Stacked'})));
    parser.addParameter('SaveAs', '', @(x) isempty(x) || ischar(x));
end
parser.parse(this, varargin{:});
opt = parser.Options;

%--------------------------------------------------------------------------

nameBlk = cell(1, 0); %#ok<PREALL>
eqtnBlk = cell(1, 0); %#ok<PREALL>

blz = prepareBlazer(this, opt.Kind, parser.Unmatched);
run(blz);

if blz.IsSingular
    throw( exception.Base('Steady:StructuralSingularity', 'error') );
end

[eqtnBlk, nameBlk, blkType] = getHuman(this, blz);

if ~isempty(opt.SaveAs)
    names = this.Quantity.Name;
    equations = this.Equation.Input;
    saveAs(blz, names, equations, opt.SaveAs);
end

end%


function [blkEqnHuman, blkQtyHuman, blkType] = getHuman(this, blz)
    numBlocks = numel(blz.Block);
    blkEqnHuman = cell(1, numBlocks);
    blkQtyHuman = cell(1, numBlocks);
    blkType = repmat(solver.block.Type.SOLVE, 1, numBlocks);
    for i = 1 : numBlocks
        ithBlk = blz.Block{i};
        blkEqnHuman{i} = this.Equation.Input( ithBlk.PosEqn );
        blkQtyHuman{i} = this.Quantity.Name( ithBlk.PosQty );
        blkType(i) = ithBlk.Type;
    end
end%

