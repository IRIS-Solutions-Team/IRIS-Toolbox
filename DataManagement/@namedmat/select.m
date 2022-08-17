function [this, pos] = select(this, rowSelection, columnSelection)

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

