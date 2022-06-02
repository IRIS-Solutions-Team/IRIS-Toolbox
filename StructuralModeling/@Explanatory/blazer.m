% blazer  Determine the order of execution within an Explanatory array
%{
% ## Syntax ##
%
%
%     [blocks, variables, equations, period] = function(xq, ...)
%
%
% ## Input Arguments ##
%
%
% __`xq`__ [ Explanatory ]
% >
% An array of Explanatory objects whose equations will be reordered
% block recursively.
%
%
% ## Output Arguments ##
%
%
% __`blocks`__ [ cell ]
% >
% Cell array whose each cell represents one block of equations; the cells
% contain the equation IDs, i.e. their positions in the original array
% `xq`.
%
%
% __`variables`__ [ cell ]
% >
% Cell array whose each cell represents one block of equations; the cells
% contain a string array with the names of the respective LHS variables.
%
%
% __`equations`__ [ cell ]
% >
% Cell array whose each cell represents one block of equations; the cells
% contain a string array with the equations. 
%
%
% __`period`__ [ logical ]
% >
% Logical array indicating whether the corresponding equation will be
% evaluated as a static assignment (all periods at once) or iterated period
% by period; the `period` indicator is only valid for equations that are
% run individually, i.e. not as part of a multiple-equation block;
% multiple-equation blocks are always interate period by period.
%
%
% ## Options ##
%
%
% __`Period=@auto`__ [ `@auto` | `true` | `false` ]
% >
% Mode of execution: `Period=true` means the equations will be iterated
% period by period; `Period=false` means the equations will be evaluated
% as a static assignment; `Period=@auto` means the model of execution will
% be determined for each equation from its structure.
%
%
% __`Reorder=true`__ [ `true` | `false` ]
% >
% Reorder the equations block recursively; if `Reorder=false`, the
% equations will be executed as one block in their original order.
%
%
% __`SaveAs=''`__ [ empty | char | string ]
% >
% Save the reordered system of equations under the specified name.
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

% >=R2019b
%{
function [blocks, variableBlocks, equationBlocks, period] = blazer(this, opt)

arguments
    this Explanatory

    opt.Reorder (1, 1) logical = true
    opt.SaveAs (1, 1) string = ""
    opt.Period (1, 1) = @auto
end
%}
% >=R2019b


% <=R2019a
%(
function [blocks, variableBlocks, equationBlocks, period] = blazer(this, varargin)

persistent ip
if isempty(ip)
    ip = extend.InputParser();
    addParameter(ip, "Reorder", true);
    addParameter(ip, "SaveAs", "");
    addParameter(ip, "Period", @auto);
end
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


newlineString = string(newline( ));
numEquations = numel(this);
lhsNames = [this(:).LhsName];
inputStrings = [this(:).InputString]; 
if numEquations==1
    opt.Reorder = false;
end


%
% Resolve Reorder= option
%
if islogical(opt.Reorder)
    if opt.Reorder
        blocks = hereReorderGlobally( );
    else
        if isequal(opt.Period, @auto) || isequal(opt.Period, true)
            blocks = {1 : numEquations};
        else
            blocks = num2cell(1 : numEquations);
        end
    end
else
    if isequal(round(sort([opt.Reorder{:}])), 1:numEquations)
        blocks = opt.Reorder; 
    else
        hereThrowInvalidReorder( );
    end
end
numBlocks = numel(blocks);


%
% Determined the period status of single-equation blocks
%
if isequal(opt.Period, @auto)
    period = true(size(this));
else
    period = repmat(opt.Period, size(this));
end
if isequal(opt.Period, @auto)
    inxSingletonBlocks = cellfun('length', blocks)==1;
    if any(inxSingletonBlocks)
        period(inxSingletonBlocks) = [this(inxSingletonBlocks).NeedsIterate];
    end
end

[variableBlocks, equationBlocks] = hereGetHumanBlocks( );

if isscalar(opt.SaveAs) && strlength(opt.SaveAs)>0
    hereSaveAs( );
end

return


    function blocks = hereReorderGlobally( )
        %
        % Set up the global incidence matrix
        %
        allNames = {this(:).VariableNames};
        inc = diag(true(1, numEquations));
        for ii = 1 : numEquations
            inc(ii, ismember(lhsNames, allNames{ii})) = true;
        end

        %
        % Run blazer globally
        %
        [ordInc, ordEquations, ordVariables] = solver.blazer.Blazer.reorder(inc);
        [blocks, blocksVariables] = solver.blazer.Blazer.getBlocks(ordInc, ordEquations, ordVariables);
        blocks = cellfun(@(x) reshape(sort(x), 1, [ ]), blocks, 'UniformOutput', false);
        blocksVariables = cellfun(@(x) reshape(sort(x), 1, [ ]), blocksVariables, 'UniformOutput', false);

        %
        % Make sure LHS variables and their equations remain linked
        %
        if ~isequal(blocks, blocksVariables)
            hereThrowCannotSplitIntoBlocks( );
        end

        numBlocks = numel(blocks);
        for ii = find(cellfun('length', blocks)>1)
            blocks{ii} = hereReorderLocally(blocks{ii});
        end

        return

            function block = hereReorderLocally(block)
                lhsNamesInBlock = [this(block).LhsName];
                numEquationsInBlock = numel(block);
                incInBlock = diag(true(1, numEquationsInBlock));
                for jj = 1 : numEquationsInBlock
                    this__ = this(block(jj));
                    % Names of all current dated variables on the RHS in
                    % this equation
                    incInEquation = [this__.ExplanatoryTerms.Incidence];
                    incInEquation = incInEquation(imag(incInEquation)==0);
                    currentDatedVariablesInEquation = this__.VariableNames(incInEquation);
                    incInBlock(jj, ismember(lhsNamesInBlock, currentDatedVariablesInEquation)) = true;
                end
                [ordIncInBlock, ordBlock] = solver.blazer.Blazer.reorder(incInBlock, block);
                if any(any(tril(ordIncInBlock, -1)))
                    hereThrowCannotSplitIntoBlocks( );
                end
                block = fliplr(ordBlock);
            end%
    end%




    function [variableBlocks, equationBlocks] = hereGetHumanBlocks( )
        variableBlocks = cellfun(@(x) reshape([lhsNames(x)], [ ], 1), blocks, 'UniformOutput', false);
        equationBlocks = cellfun(@(x) reshape(inputStrings(x), [ ], 1), blocks, 'UniformOutput', false);
    end%




    function hereSaveAs( )
        allNames = collectAllNames(this);
        s = "";
        for i = 1 : numBlocks
            numEquationsInBlock = numel(blocks{i});
            if numEquationsInBlock==1
                if period(blocks{i})
                    type = solver.block.Type.ITERATE_TIME;
                else
                    type = solver.block.Type.ASSIGN;
                end
            else
                type = solver.block.Type.ITERATE_TIME;
            end
            blockObj = solver.block.Explanatory( );
            blockObj.Type = type;
            blockObj.PtrEquations = blocks{i};
            s = s + newlineString + newlineString ...
                + print(blockObj, i, [ ], inputStrings);
        end
        s = newlineString + "% LHS Variables: (" + join(lhsNames, ", ") + ")" ...
            + newlineString + "% RHS-Only Variables: (" + join(setdiff(allNames, lhsNames), ", ") + ")" ...
            + s;
        solver.blazer.Blazer.wrapAndSave(s, opt.SaveAs, numBlocks, numEquations);
    end%




    function hereThrowInvalidReorder( )
        thisError = [ 
            "Explanatory:InvalidReorder"
            "The option Reorder= fails to constitute a valid reordering of the Explanatory "
            "object or array; the option Reorder= needs to be true, false or a user-specified "
            "permutation of {1, ..., #equations}." 
        ];
        throw(exception.Base(thisError, 'error'));
    end%
end%


%
% Local Functions
%


function hereThrowCannotSplitIntoBlocks( )
    thisError = [ 
        "Explanatory:CannotSplitIntoBlocks"
        "Error reordering the Explanatory array block recursively. "
        "Make sure the equations are ordered correctly in the source file "
        "and rerun your task setting Reorder=false, or use the option "
        "Reorder= directly to specify your own block reordering."
    ];
    throw(exception.Base(thisError, 'error'));
end%

