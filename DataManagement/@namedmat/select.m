function [This,Pos] = select(This,RowSelect,ColSelect)
% select  Select submatrix by referring to row names and column names.
%
% Syntax
% =======
%
%     [XX,Pos] = select(X,RowSelect,ColSelect)
%     [XX,Pos] = select(X,Select)
%
% Input arguments
% ================
% 
% * `X` [ namedmat ] - Matrix or array with named rows and columns.
%
% * `RowSelect` [ char | cellstr ] - Selection of row names.
%
% * `ColSelect` [ char | cellstr ] - Selection of column names.
%
% * `Select` [ char | cellstr ] - Selection of names that will be applied
% to both rows and columns.
%
% Output arguments
% =================
%
% * `XX` [ namedmat ] - Submatrix with named rows and columns.
%
% * `Pos` [ cell ] - `Pos{1}` is a vector of rows included in the submatrix
% `XX`, `Pos{2}` is a vector of columns included in the submatrix `XX`.
%
% Description
% ============
%
% Example
% ========

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

try
    ColSelect; %#ok<VUNUS>
catch %#ok<CTCH>
    if iscell(RowSelect) && length(RowSelect) == 2 ...
            && iscell(RowSelect{1}) && iscell(RowSelect{2})
        ColSelect = RowSelect{2};
        RowSelect = RowSelect{1};
    else
        ColSelect = RowSelect;
    end
end

pp = inputParser( );
pp.addRequired('RowSelect',@(x) ischar(x) || iscellstr(x));
pp.addRequired('ColSelect',@(x) ischar(x) || iscellstr(x));
pp.parse(RowSelect,ColSelect);

%--------------------------------------------------------------------------

rowNames = This.RowNames;
colNames = This.ColNames;

[X,Pos] = namedmat.myselect(double(This), ...
    rowNames,colNames,RowSelect,ColSelect);

This = namedmat(X,rowNames(Pos{1}),colNames(Pos{2}));

end
