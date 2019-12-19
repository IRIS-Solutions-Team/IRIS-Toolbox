function [nameBlk, eqtnBlk, blkType, blazer] = blazer(this, varargin)
% blazer  Reorder dynamic or steady equations and variables into sequential block structure
%{
% ## Syntax ##
%
%     [nameBlk, eqtnBlk, blkType, blazerObj] = blazer(m, ...)
%
%
% ## Input Arguments ##
%
% __`m`__ [ Model ] -
% Model object.
%
%
% ## Output Arguments ##
%
% __`m`__ [ model ] -
% Model object with variables and steady-state equations regrouped to
% create sequential block structure.
%
% __`nameBlk`__ [ cell ] -
% Cell of cellstr with variable names in each block.
%
% __`eqtnBlk`__ [ cell ] - 
% Cell of cellstr with equations in each block.
%
% __`blkType`__ [ solver.block.Type ] -
% Type of each equation block: `SOLVE` or `ASSIGN`.
%
%
% ## Options ##
%
% __`Endogenize={ }`__ [ cellstr | char | empty ] -
% List of parameters that will be endogenized in steady equations.
%
% __`Exogenize={ }`__ [ cellstr | char | empty ] -
% List of transition or measurement variables that will be exogenized in
% steady equations.
%
% __`Kind='Steady'`__ [ `'Current'` | `'Stacked'` | `'Steady'` ] -
% The kind of sequential block analysis that will be performed.
%
%
% ## Description ##
%
% Three kinds of sequential block analysis can be performed:
%
% * `'Steady'` - Investigate steady-state equations, considering lags and
% leads to be the same entity as the respective current dated variable.
%
% * `'Current'` - Investigate the current dated variables in dynamic
% equations, taking lags and leads as given.
%
% * `'Stacked'` - Investigate a whole structure of time-stacked equations
% (not available yet).
%
%
% ### Reordering Algorithm ###
%
% The reordering algorithm first identifies equations with a single
% variable in each, and variables occurring in a single equation each, and
% then uses a combination of column and row approximate minimum degree
% permutations (`colamd`) followed by a Dulmage-Mendelsohn permutation
% (`dmperm`).
%
%
% ### Output Returned from Blazer ###
%
% The output arguments `NameBlk` and `EqtnBlk` are 1-by-N cell arrays, 
% where N is the number of blocks, and each cell is a 1-by-Kn cell array of
% strings, where Kn is the number of variables and equations in block N.
%
%
% ## Example ##
%
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('model.blazer');
    parser.KeepUnmatched = true;
    parser.addRequired('model', @(x) isa(x, 'model'));
    parser.addParameter('Kind', 'Steady', @(x) ischar(x) && any(strcmpi(x, {'Steady', 'Current', 'Stacked'})));
    parser.addParameter('SaveAs', '', @(x) isempty(x) || ischar(x));
end
parser.parse(this, varargin{:});
opt = parser.Options;

%--------------------------------------------------------------------------

nameBlk = cell(1, 0); %#ok<PREALL>
eqtnBlk = cell(1, 0); %#ok<PREALL>

blazer = prepareBlazer(this, opt.Kind, parser.Unmatched);
run(blazer);

if blazer.IsSingular
    throw(exception.Base('Steady:StructuralSingularity', 'warning'));
end

[eqtnBlk, nameBlk, blkType] = getHuman(blazer);

if ~isempty(opt.SaveAs)
    saveAs(blazer, opt.SaveAs);
end

end%


%
% Local Functions
%


function [blkEqnHuman, blkQtyHuman, blkType] = getHuman(blazer)
    numBlocks = numel(blazer.Block);
    blkEqnHuman = cell(1, numBlocks);
    blkQtyHuman = cell(1, numBlocks);
    blkType = repmat(solver.block.Type.SOLVE, 1, numBlocks);
    for i = 1 : numBlocks
        ithBlk = blazer.Block{i};
        blkEqnHuman{i} = blazer.Model.Equation.Input( ithBlk.PosEqn );
        blkQtyHuman{i} = blazer.Model.Quantity.Name( ithBlk.PosQty );
        blkType(i) = ithBlk.Type;
    end
end%

