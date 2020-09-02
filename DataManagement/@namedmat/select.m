function [this, pos] = select(this, rowSelection, columnSelection)
% select  Select submatrix by referring to row names and column names.
%
% Syntax
% =======
%
%     [XX, pos] = select(x, rowSelection, columnSelection)
%     [XX, pos] = select(x, Select)
%
% Input arguments
% ================
% 
% * `x` [ namedmat ] - Matrix or array with named rows and columns.
%
% * `rowSelection` [ char | cellstr ] - Selection of row names.
%
% * `columnSelection` [ char | cellstr ] - Selection of column names.
%
% * `Select` [ char | cellstr ] - Selection of names that will be applied
% to both rows and columns.
%
% Output arguments
% =================
%
% * `XX` [ namedmat ] - Submatrix with named rows and columns.
%
% * `pos` [ cell ] - `pos{1}` is a vector of rows included in the submatrix
% `XX`, `pos{2}` is a vector of columns included in the submatrix `XX`.
%
% Description
% ============
%
% Example
% ========

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

try
    columnSelection; %#ok<VUNUS>
catch %#ok<CTCH>
    if iscell(rowSelection) && numel(rowSelection)==2 ...
            && iscell(rowSelection{1}) && iscell(rowSelection{2})
        columnSelection = rowSelection{2};
        rowSelection = rowSelection{1};
    else
        columnSelection = rowSelection;
    end
end

pp = inputParser( );
pp.addRequired('rowSelection', @(x) isstring(x) || ischar(x) || iscellstr(x));
pp.addRequired('columnSelection', @(x) isstring(x) || ischar(x) || iscellstr(x));
pp.parse(rowSelection, columnSelection);

%--------------------------------------------------------------------------

rowSelection = reshape(string(rowSelection), 1, [ ]);
columnSelection = reshape(string(columnSelection), 1, [ ]);
rowNames = this.RowNames;
colNames = this.ColNames;

[x, pos] = namedmat.myselect(double(this), ...
    rowNames, colNames, rowSelection, columnSelection);

this = namedmat(x, rowNames(pos{1}), colNames(pos{2}));

end%

