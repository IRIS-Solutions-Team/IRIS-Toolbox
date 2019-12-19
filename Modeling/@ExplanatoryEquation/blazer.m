function [blocks, variableBlocks, equationBlocks] = blazer(this, varargin)
% blazer  Determine the order of execution within an ExplanatoryEquation array

% Invoke unit tests
%(
if nargin==2 && isequal(varargin{1}, '--test')
    blocks = functiontests({
        @incidenceTest
    });
    blocks = reshape(blocks, [ ], 1);
    return
end
%)

%--------------------------------------------------------------------------

numEquations = numel(this);
lhsNames = [this(:).LhsName];

if numEquations==1
    blocks = {1};
    if nargout>=2
        [variableBlocks, equationBlocks] = hereGetHumanBlocks( );
    end
    return
end

%
% Set up the incidence matrix
%
rhsNames = {this(:).VariableNames};
inc = diag(true(1, numEquations));
for i = 1 : numEquations
    inc(i, ismember(lhsNames, rhsNames{i})) = true;
end

%
% Reorder using the Blazer class
%
[ordInc, ordEquations, ordVariables] = solver.blazer.Blazer.reorder(inc);
[blocks, blocksVariables] = solver.blazer.Blazer.getBlocks(ordInc, ordEquations, ordVariables);
blocks = cellfun(@(x) reshape(sort(x), 1, [ ]), blocks, 'UniformOutput', false);
blocksVariables = cellfun(@(x) reshape(sort(x), 1, [ ]), blocksVariables, 'UniformOutput', false);

%
% Make sure LHS variables and their equations remain linked
%
if ~isequal(blocks, blocksVariables)
    blocks = {1:numEquations};
    thisWarning = [ "ExplanatoryEquation:CannotSplitIntoBlocks"
                    "Cannot split an ExplanatoryEquation array into sequential blocks." ];
    throw(exception.Base(thisWarning, 'warning'));
end
    
if nargout>=2
    [variableBlocks, equationBlocks] = hereGetHumanBlocks( );
end

return

    function [variableBlocks, equationBlocks] = hereGetHumanBlocks( )
        variableBlocks = cellfun(@(x) reshape([lhsNames(x)], [ ], 1), blocks, 'UniformOutput', false);
        equationBlocks = cellfun(@(x) reshape([this(x).InputString], [ ], 1), blocks, 'UniformOutput', false);
    end%
end%




%
% Unit Tests
%
%(
function incidenceTest(testCase)
    xq = ExplanatoryEquation.fromString([
        "x = y{-1} + z{-1} + a"
        "a = b"
        "y = y{-1}"
        "z = x{-1}"
    ]);
end%
%)
