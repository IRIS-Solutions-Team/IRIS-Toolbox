function varargout = blazer(this, varargin)
% blazer  Determine the order of execution within an ExplanatoryEquation array
%{
% ## Syntax ##
%
%
%     [blocks, variables, equations, dynamic] = function(xq, ...)
%
%
% ## Input Arguments ##
%
%
% __`xq`__ [ ExplanatoryEquation ]
% >
% An array of ExplanatoryEquation objects whose equations will be reordered
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
% __`dynamic`__ [ logical ]
% >
% Logical array indicating whether the corresponding equation will be
% evaluated as a static assignment (all periods at once) or iterated period
% by period; the `dynamic` indicator is only valid for equations that are
% run individually, i.e. not as part of a multiple-equation block;
% multiple-equation blocks are always interate period by period.
%
%
% ## Options ##
%
%
% __`Dynamic=@auto`__ [ `@auto` | `true` | `false` ]
% >
% Mode of execution: `Dynamic=true` means the equations will be iterated
% period by period; `Dynamic=false` means the equations will be evaluated
% as a static assignment; `Dynamic=@auto` means the model of execution will
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
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

% Invoke unit tests
%(
if nargin==2 && isequal(varargin{1}, '--test')
    varargout{1} = unitTests( );
    return
end
%)


persistent pp
if isempty(pp)
    pp = extend.InputParser('ExplanatoryEquation.blazer');
    pp.KeepUnmatched = true;

    addRequired(pp, 'equations', @(x) isa(x, 'ExplanatoryEquation'));

    addParameter(pp, 'Reorder', true, @(x) validate.logicalScalar(x) || (iscell(x) && all(cellfun(@(y) isnumeric(y), x))));
    addParameter(pp, {'SaveAs', 'SaveBlazerAs'}, [ ], @(x) isempty(x) || validate.string(x));
    addParameter(pp, 'Dynamic', @auto, @(x) isequal(x, @auto) || validate.logicalScalar(x));
end
parse(pp, this, varargin{:});
opt = pp.Options;

%--------------------------------------------------------------------------

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
        if isequal(opt.Dynamic, @auto) || isequal(opt.Dynamic, true)
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
% Determined the dynamic status of single-equation blocks
%
if isequal(opt.Dynamic, @auto)
    dynamicStatus = true(size(this));
else
    dynamicStatus = repmat(opt.Dynamic, size(this));
end
if isequal(opt.Dynamic, @auto)
    inxSingletonBlocks = cellfun('length', blocks)==1;
    if any(inxSingletonBlocks)
        dynamicStatus(inxSingletonBlocks) = [this(inxSingletonBlocks).NeedsIterate];
    end
end

[variableBlocks, equationBlocks] = hereGetHumanBlocks( );

if ~isempty(opt.SaveAs) && string(opt.SaveAs)~=""
    hereSaveAs( );
end

varargout = { blocks, variableBlocks, equationBlocks, dynamicStatus };

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
                    incInEquation = [this__.Explanatory.Incidence];
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




    function blazerObj = hereSaveAs( )
        allNames = collectAllNames(this);
        c = "";
        for i = 1 : numBlocks
            numEquationsInBlock = numel(blocks{i});
            if numEquationsInBlock==1
                if dynamicStatus(blocks{i})
                    type = solver.block.Type.ITERATE_TIME;
                else
                    type = solver.block.Type.ASSIGN;
                end
            else
                type = solver.block.Type.ITERATE_TIME;
            end
            keyword = string(type.SaveAsKeyword);
            c = c + newlineString + newlineString ...
                + solver.block.Block.printBlock(i, keyword, inputStrings(blocks{i}));
        end
        c = newlineString + "% LHS Variables: (" + join(lhsNames, ", ") + ")" ...
            + newlineString + "% RHS-Only Variables: (" + join(setdiff(allNames, lhsNames), ", ") + ")" ...
            + c;
        solver.blazer.Blazer.wrapAndSave(c, opt.SaveAs, numBlocks, numEquations);
    end%




    function hereThrowInvalidReorder( )
        thisError = [ 
            "ExplanatoryEquation:InvalidReorder"
            "The option Reorder= fails to constitute a valid reordering of the ExplanatoryEquation "
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
        "ExplanatoryEquation:CannotSplitIntoBlocks"
        "Error reordering the ExplanatoryEquation array block recursively. "
        "Make sure the equations are ordered correctly in the source file "
        "and rerun your task setting Reorder=false, or use the option "
        "Reorder= directly to specify your own block reordering."
    ];
    throw(exception.Base(thisError, 'error'));
end%




%
% Unit Tests
%
%(
function tests = unitTests( )
    tests = functiontests({
        @blazerTest
        @saveAsTest
    });
    tests = reshape(tests, [ ], 1);
end%


function blazerTest(testCase)
    xq = ExplanatoryEquation.fromString([
        "x = y{-1} + z{-1} + a"
        "a = b"
        "y = y{-1}"
        "z = x{-1}"
    ]);
    act = blazer(xq);
    assertEqual(testCase, numel(act{1}), 1);
    assertEqual(testCase, numel(act{2}), 1);
    assertEqual(testCase, sort(act{3}), sort(int16([1, 4])));
end%


function saveAsTest(testCase)
    xq = ExplanatoryEquation.fromString([
        "x = y{-1} + z{-1} + a"
        "a = b"
        "y = y{-1}"
        "z = x{-1}"
    ]);
    fileName = './test_blazer.model';
    blazer(xq, 'SaveAs=', fileName);
    act = file2char(fileName); 
    assertEqual(testCase, contains(act, 'Number of Blocks: 3'), true);
    assertEqual(testCase, contains(act, 'Assign'), true); 
    assertEqual(testCase, contains(act, 'Iterate'), true); 
    delete(fileName);
end%
%)
