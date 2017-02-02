function [nameBlk, eqtnBlk, blkType, blz] = blazer(this, varargin)
% blazer  Reorder dynamic or steady equations and variables into sequential block structure.
%
% Syntax
% =======
%
%     [NameBlk, EqtnBlk, BlkType] = blazer(M, ...)
%
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object.
%
%
% Output arguments
% =================
%
% * `M` [ model ] - Model object with variables and steady-state equations
% regrouped to create sequential block structure.
%
% * `NameBlk` [ cell ] - Cell of cellstr with variable names in each block.
%
% * `EqtnBlk` [ cell ] - Cell of cellstr with equations in each block.
%
% * `BlkType [ solver.block.Type ] - Type of each equation block: `SOLVE` or
% `ASSIGN`.
%
%
% Options
% ========
%
% * `'endogenize='` [ cellstr | char ] - List of parameters that will be
% endogenized in steady equations.
%
% * `'exogenize='` [ cellstr | char ] - List of transition or measurement
% variables that will be exogenized in steady equations.
%
% * `'kind='` [ `'dynamic'` | *`'steady'`* ] - The kind of equations on
% which sequential block analysis will be performed.
%
%
% Description
% ============
%
% The reordering algorithm first identifies equations with a single
% variable in each, and variables occurring in a single equation each, and
% then uses a combination of column and row approximate minimum degree
% permutations (`colamd`) followed by a Dulmage-Mendelsohn permutation
% (`dmperm`).
%
% The output arguments `NameBlk` and `EqtnBlk` are 1-by-N cell arrays,
% where N is the number of blocks, and each cell is a 1-by-Kn cell array of
% strings, where Kn is the number of variables and equations in block N.
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

opt = passvalopt('model.blazer', varargin{:});

%--------------------------------------------------------------------------

nameBlk = cell(1,0); %#ok<PREALL>
eqtnBlk = cell(1,0); %#ok<PREALL>

if this.IsLinear
    throw( exception.Base('Blazer:CannotRunLinear', 'warning') );
    return %#ok<UNRCH>
end

blz = prepareBlazer(this, opt.kind, opt);
run(blz);

if blz.IsSingular
    throw( exception.Base('Steady:StructuralSingularity', 'error') );
end

[eqtnBlk, nameBlk, blkType] = getHuman(blz, this);

if ~isempty(opt.saveas)
    saveAs(blz, this, opt.saveas);
end

end
