function C = speclatexcode(This,IChild,NChild)
% speclatexcode  [Not a public function] LaTeX code for report/series data.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

isLastChild = IChild < NChild;
par = This.parent;
[x,time] = getdata(This,This.data, ...
    par.options.range,This.options.colstruct);
time = time.';
x = x(:,:);
C = '';
text = This.caption;
br = sprintf('\n');
nx = size(x,2);
for iRow = 1 : nx
    if iRow <= numel(This.options.marks)
        mark = This.options.marks{iRow};
    else
        mark = '';
    end
    if iRow > 1
        C = [C,br]; %#ok<AGROW>
    end
    isRowHighlight = This.options.rowhighlight(min(iRow,end));
    if isRowHighlight
        C = [C,'\rowcolor{highlightcolor} ']; %#ok<AGROW>
        This.hInfo.package.colortbl = true;
    end 
    C = [C,latexonerow(This,iRow,time,x(:,iRow),mark,text)]; %#ok<AGROW>
    if isRowHighlight && isLastChild
        C = [C,'\rowcolor{white}']; %#ok<AGROW>
    end
end

end