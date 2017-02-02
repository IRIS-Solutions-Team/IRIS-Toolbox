function This = mtimes(This,List)
% See help on dbase/dbmtimes.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

pp = inputParser( );
pp.addRequired('D',@isstruct);
pp.addRequired('List',@(x) iscellstr(x) || ischar(x));
pp.parse(This,List);

%--------------------------------------------------------------------------

if ischar(List)
    List = regexp(List,'\w+','match');
end

f = fieldnames(This).';
c = struct2cell(This).';
[fNew,inx] = intersect(f,List);
This = cell2struct(c(inx),fNew,2);

end
