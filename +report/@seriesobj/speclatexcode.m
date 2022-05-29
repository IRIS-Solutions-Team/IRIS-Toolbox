function code = speclatexcode(this, ithChild, numOfChildren)
% speclatexcode  LaTeX code for report/series data.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

BR = sprintf('\n');

%--------------------------------------------------------------------------

isLastChild = ithChild==numOfChildren;
par = this.parent;
[x, time] = getdata(this, this.data, par.options.range, this.options.colstruct);
time = time.';
x = x(:, :);
code = '';
text = this.caption;
nx = size(x, 2);
for iRow = 1 : nx
    if iRow<=numel(this.options.marks)
        mark = this.options.marks{iRow};
    else
        mark = '';
    end
    if iRow>1
        code = [code, BR]; %#ok<AGROW>
    end
    isRowHighlight = this.options.rowhighlight(min(iRow, end));
    if isRowHighlight
        code = [code, '\rowcolor{highlightcolor} ']; %#ok<AGROW>
        this.hInfo.package.colortbl = true;
    end 
    code = [code, latexonerow(this, iRow, time, x(:, iRow), mark, text)]; %#ok<AGROW>
    if isRowHighlight && isLastChild
        code = [code, '\rowcolor{white}']; %#ok<AGROW>
    end
end

end
