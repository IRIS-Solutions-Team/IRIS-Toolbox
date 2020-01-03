function varargout = locate(items, list, varargin)
% locate  Find positions of selected items in a list
%{
% ## Syntax ##
%
%     pos = textual.locate(items, list)
%
%
% ## Input Arguments ##
%
% __`items`__ [ string | cellstr | char ]
% >
% List of strings, each of which will be located in the `list`.
%
% __`list`__ [ string | cellstr | char ]
% >
% List of strings within which the `items` will be located.
%
%
% ## Output Arguments ##
%
% __`pos`__ [ numeric ]
% >
% Position of each item from the `items` in the `list`.
%
%
% ## Description ##
%
% The function returns a numeric array of the same size as the input
% `items`. Each element of the `pos` is either the position (linear index)
% of the corresponding item in the `list`, or `NaN` if the item is not
% found. If there are multiple occurences of an item in the `list`, the
% first will be reported.
%
%
% ## Example ##
%
%     >> items = ["aa", "BB", "C_"];
%     >> list = ["BB", "x", "y", "zz", "C_", "C_"];
%     >> textual.locate(items, list)                
%     ans =
%        NaN     1     5
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

% Invoke unit tests
%(
if nargin==1 && isequal(items, '--test')
    varargout{1} = unitTests( );
    return
end
%)


%--------------------------------------------------------------------------

items = string(items);
list = string(list);
pos = nan(size(items));
for i = 1 : numel(items)
    x_ = find(items(i)==list, 1, varargin{:});
    if ~isempty(x_)
        pos(i) = x_;
    end
end


%<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
varargout{1} = pos;
%<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

end%




%
% Unit Tests 
%
%(
function tests = unitTests( )
    tests = functiontests({
        @stringTest
        @stringFirstTest
        @stringLastTest
        @cellstrTest
    });
    tests = reshape(tests, [ ], 1);
end%


function stringTest(this)
    items = ["aa", "BB", "C_"];
    list = ["BB", "x", "y", "zz", "C_", "C_"];
    pos = textual.locate(items, list);
    assertEqual(this, pos, [NaN, 1, 5]);
end%


function stringFirstTest(this)
    items = ["aa", "BB", "C_"];
    list = ["BB", "x", "y", "zz", "C_", "C_"];
    pos = textual.locate(items, list, 'first');
    assertEqual(this, pos, [NaN, 1, 5]);
end%


function stringLastTest(this)
    items = ["aa", "BB", "C_"];
    list = ["BB", "x", "y", "zz", "C_", "C_"];
    pos = textual.locate(items, list, 'last');
    assertEqual(this, pos, [NaN, 1, 6]);
end%


function cellstrTest(this)
    items = {'aa', 'BB', 'C_'};
    list = {'BB', 'x', 'y', 'zz', 'C_', 'C_'};
    pos = textual.locate(items, list);
    assertEqual(this, pos, [NaN, 1, 5]);
end%
%)

