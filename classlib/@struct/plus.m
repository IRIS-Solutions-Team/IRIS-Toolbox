function D = plus(D1,D2)
% See help on dbase/dbplus.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

pp = inputParser( );
pp.addRequired('D1',@isstruct);
pp.addRequired('D2',@isstruct);
pp.parse(D1,D2);

%--------------------------------------------------------------------------

names = [fieldnames(D1);fieldnames(D2)];
values = [struct2cell(D1);struct2cell(D2)];
[names,inx] = unique(names,'last');
D = cell2struct(values(inx),names);

end