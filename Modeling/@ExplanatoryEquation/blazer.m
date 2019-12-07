function [blocks, humanBlocks] = blazer(this, varargin)
% blazer  Determine the order of execution within an ExplanatoryEquation array

% Invoke unit tests
%(
if nargin==2 && isequal(varargin{1}, '--test')
    blocks = functiontests({
        @incidenceTest
    });
    return
end
%)

%--------------------------------------------------------------------------

numEquations = numel(this);
lhsNames = [this(:).LhsName];

if numEquations==1
    blocks = {1};
    humanBlocks = hereGetHumanBlocks( );
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
    keyboard
end
    
if nargout>=2
    humanBlocks = hereGetHumanBlocks( );
end

return

    function humanBlocks = hereGetHumanBlocks( )
        humanBlocks = cellfun(@(x) lhsNames(x), blocks, 'UniformOutput', false);
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
