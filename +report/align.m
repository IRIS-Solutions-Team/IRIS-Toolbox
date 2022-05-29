% align  Vertically align the following K objects.
%
% Syntax
% =======
%
%     P.align(Caption,K,NCol,...)
%
% Input arguments
% ================
%
% * `P` [ struct ] - Report object created by the
% [`report.new`](report/new) function.
%
% * `Caption` [ char ] - Caption displayed only when describing the
% structure of the report on the screen, but not in the actual PDF report.
%
% * `K` [ numeric ] - Number of objects following this `align`
% that will be vertically aligned.
%
% * `NCol` [ numeric ] - Number of columns in which the objects will
% vertically aligned.
%
% Options
% ========
%
% * `'hspace='` [ numeric | *`2`* ] - Horizontal space (in em units) inserted
% between two neighbouring objects.
%
% * `'separator='` [ char | *`'\medskip\par'`* ] - (Inheritable from parent
% objects) \LaTeX\ commands that will be inserted after the aligned
% objects.
%
% * `'shareCaption='` [ *`'auto'`* | true | false ] - (Inheritable from
% parent objects) Place a shared caption (title and subtitle) over each row
% of objects; the title of the first object in each row is used; `'auto'`
% means that the caption will be shared if they are identical for all
% objects in a row.
%
% * `'typeface='` [ char | *empty* ] - (Not inheritable from parent objects)
% \LaTeX\ code specifying the typeface for the align element as a whole; it
% must use the declarative forms (such as `\itshape`) and not the command
% forms (such as `\textit{...}`).
%
% Description
% ============
%
% Vertically aligned can be the following types of objects:
%
% * [`figure`](report/figure)
% * [`table`](report/table)
% * [`matrix`](report/matrix)
% * [`array`](report/array)
%
% Note that the `align` object itself has no caption (even if you specify
% one it will not be used). Only the objects within `align` will be given
% captions. If the objects aligned on one row have identical captions (i.e.
% both titles and subtitles), only one caption will be displayed centred
% above the objects.
%
% Because [`empty`](report/empty) objects count in the total number of
% objects inluded in `align`, you can use [`empty`](report/empty) in to
% create blank space in a particular position.
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

