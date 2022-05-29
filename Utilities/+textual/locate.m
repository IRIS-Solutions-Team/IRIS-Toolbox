% locate  Find positions of selected items in a list
%{
% Syntax
%--------------------------------------------------------------------------
%
%     pos = textual.locate(items, list)
%
%
% Input Arguments
%--------------------------------------------------------------------------
%
%
% __`items`__ [ string | cellstr | char ]
%
%     List of strings, each of which will be located in the `list`.
%
%
% __`list`__ [ string | cellstr | char ]
%
%     List of strings within which the `items` will be located.
%
%
% Output Arguments
%--------------------------------------------------------------------------
%
%
% __`pos`__ [ numeric ]
%
%     Position of each item from the `items` in the `list`.
%
%
% Description
%--------------------------------------------------------------------------
%
%
% The function returns a numeric array of the same size as the input
% `items`. Each element of the `pos` is either the position (linear index)
% of the corresponding item in the `list`, or `NaN` if the item is not
% found. If there are multiple occurences of an item in the `list`, the
% first will be reported.
%
%
% Example
%--------------------------------------------------------------------------
%
%
%     >> items = ["aa", "BB", "C_"];
%     >> list = ["BB", "x", "y", "zz", "C_", "C_"];
%     >> textual.locate(items, list)                
%     ans =
%        NaN     1     5
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function pos = locate(items, list, varargin)

%--------------------------------------------------------------------------

items = string(items);
list = string(list);

pos = nan(size(items));
for i = 1 : numel(items)
    pos__ = find(items(i)==list, 1, varargin{:});
    if ~isempty(pos__)
        pos(i) = pos__;
    end
end

end%




%
% Unit Tests 
%
%{
##### SOURCE BEGIN #####
% saveAs=textual/locateUnitTest.m

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);


%% Test String
    items = ["aa", "BB", "C_"];
    list = ["BB", "x", "y", "zz", "C_", "C_"];
    pos = textual.locate(items, list);
    assertEqual(testCase, pos, [NaN, 1, 5]);


%% Test String First 
    items = ["aa", "BB", "C_"];
    list = ["BB", "x", "y", "zz", "C_", "C_"];
    pos = textual.locate(items, list, 'first');
    assertEqual(testCase, pos, [NaN, 1, 5]);



%% Test String Last
    items = ["aa", "BB", "C_"];
    list = ["BB", "x", "y", "zz", "C_", "C_"];
    pos = textual.locate(items, list, 'last');
    assertEqual(testCase, pos, [NaN, 1, 6]);



%% Test Cellstr
    items = {'aa', 'BB', 'C_'};
    list = {'BB', 'x', 'y', 'zz', 'C_', 'C_'};
    pos = textual.locate(items, list);
    assertEqual(testCase, pos, [NaN, 1, 5]);


##### SOURCE END #####
%}
