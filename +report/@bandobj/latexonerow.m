function C = latexonerow(This,IRow,Time,Data,Mark,Text)
% latexonerow  [Not a public function] LaTeX code for one table band row.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

br = sprintf('\n');

C = latexonerow@report.seriesobj(This, ...
    IRow,Time,Data(:,1),Mark,Text);

lowMark = This.options.low;
highMark = This.options.high;
if ~isempty(Mark)
    lowMark = [Mark,'--',lowMark];
    highMark = [Mark,'--',highMark];
end
lowString = interpret(This,lowMark);
highString = intepret(This,highMark);
C = [C,br,...
    '& & {',This.options.bandtypeface,'{',lowString,'}}', ...
    latexdata(This,IRow,Time,Data(:,2), ...
    This.options.bandtypeface,lowMark,Text), ...
    '\\',br,...
    '& & {',This.options.bandtypeface,'{',highString,'}}', ...
    latexdata(This,IRow,Time,Data(:,3), ...
    This.options.bandtypeface,highMark,Text), ...
    '\\'];

end
