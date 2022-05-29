% report  PDF Reports (report Package and Objects).
%
% New report
% ===========
%
% * [`new`](report/new) - Create new empty report object.
% * [`copy`](report/copy) - Create a copy of a report object.
%
% Compiling PDF report
% =====================
%
% * [`publish`](report/publish) - Compile PDF from report object.
%
% Top-level objects
% ==================
%
% * [`table`](report/table) - Start new table.
% * [`figure`](report/figure) - Start new figure.
% * [`userfigure`](report/userfigure) - Insert existing figure window.
% * [`matrix`](report/matrix) - Insert matrix or numeric array.
% * [`modelfile`](report/modelfile) - Write formatted model file.
% * [`array`](report/array) - Insert array with user data.
% * [`tex`](report/tex) - Include \LaTeX\ code or verbatim input in report.
%
% Inspecting and maninpulating report objects
% ============================================
%
% * [`disp`](report/disp) - Display the structure of report object.
% * [`display`](report/display) - Display the structure of report object.
% * [`findall`](report/findall) - Find all objects of a given type within report object.
%
% Figure objects
% ===============
%
% * [`graph`](report/graph) - Add graph to figure.
%
% Table and graph objects
% ========================
%
% * [`band`](report/band) - Add new data with lower and upper bounds to graph or table.
% * [`fanchart`](report/fanchart) - Add fanchart to graph.
% * [`series`](report/series) - Add new data to graph or table.
% * [`subheading`](report/subheading) - Enter subheading in table.
% * [`vline`](report/vline) - Add vertical line to graph.
% * [`highlight`](report/highlight) - Highlight range in graph.
%
% Structuring reports
% ====================
%
% * [`align`](report/align) - Vertically align the following K objects.
% * [`empty`](report/empty) - Empty report object.
% * [`include`](report/include) - Include text or LaTeX input file in the report.
% * [`merge`](report/merge) - Merge the content of two or more report objects.
% * [`pagebreak`](report/pagebreak) - Force page break.
% * [`section`](report/section) - Start new section in report.
%
% Getting on-line help on report functions
% =========================================
%
%     help report
%     help report/function_name
%
% Generic options
% ================
%
% The following generic options can be used on any of the report objects.
%
% * `'inputFormat='` [ *`'plain'` | `'latex'` ] - Input format for user
% supplied text strings (such as captions, headings, footnotes, etc);
% `'latex'` means they are assumed to be valid \LaTeX strings,
% and will be inserted straight into the report code with no modification.
%
% * `'saveAs='` [ char | *empty* ] - (Not inheritable from parent objects)
% Save the LaTeX code generated for the respective report element in a text
% file under the specified name.
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.
