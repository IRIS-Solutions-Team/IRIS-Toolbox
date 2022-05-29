% publish  Compile PDF from report object.
%
% Syntax
% =======
%
%     [OutpFile,Info] = P.publish(InpFile,...)
%
% Input arguments
% ================
%
% * `P` [ struct ] - Report object created by the `report.new` function.
%
% * `InpFile` [ char ] - File name under which the compiled PDF will be
% saved.
%
% Output arguments
% =================
%
% * `OutpFile` [ char ] - Name of the resulting PDF.
%
% * `Info` [ struct ] -  Information struct with details of building the
% PDF report; see Description.
%
% Options
% ========
%
% * `'abstract='` [ char | *empty* ] - Abstract that will displayed on the
% title page.
%
% * `'abstractWidth='` [ numeric | *`1`* ] - Width of the abstract on the
% page as a percentage of the full default width (between `0` and `1`).
%
% * `'author='` [ char | *empty* ] - List of authors on the title page
% separated with `\and` or `\\`.
%
% * `'cleanup='` [ *`true`* | `false` ] - Delete all temporary files
% created when compiling the report.
%
% * `'compile='` [ *`true`* | `false` ] - Compile the source files to an
% actual PDF; if `false` only the source files are created.
%
% * `'date='` [ char | *`'\today'`* ] - Date on the title page.
%
% * `'display='` [ *`true`* | `false` ] - Display the \LaTeX compiler
% report on the final iteration.
%
% * `'echo='` [ `true` | *`false`* ] - If `true`, the optional flag
% `'-echo'` will be used in the Matlab function `system` when compiling the
% PDF; this causes the screen output and all prompts to be displayed
% for each run of the compiler.
%
% * `'epsToPdf='` [ char | *`Inf`* ] - Command line arguments for EPSTOPDF;
% `Inf` means OS-specific arguments are used.
%
% * `'fontEnc='` [ char | *`'T1'`* ] - \LaTeX\ font encoding.
%
% * `'makeTitle='` [ `true` | *`false`* ] - Produce title page (with title,
% author, date, and abstract).
%
% * `'package='` [ char | cellstr | *empty* ] - Package or list of packages
% that will be imported in the preamble of the LaTeX file.
%
% * `'paperSize='` [ `'a4paper'` | *`'letterpaper'`* ] - Paper size.
%
% * `'orientation='` [ *`'landscape'`* | `'portrait'` ] - Paper orientation.
%
% * `'preamble='` [ char | *empty* ] - \LaTeX\ commands that will be placed
% in the \LaTeX\ file preamble.
% 
% * `'timeStamp='` [ char | *`'datestr(now( ))'`* ] - String printed in the
% top-left corner of each page.
%
% * `'tempDir='` [ char | function_handle | *`tempname(pwd( ))`* ] -
% Directory for storing temporary files; the directory is deleted at the
% end of the execution if it's empty.
%
% * `'maxRerun='` [ numeric | *`5`* ] - Maximum number of times the \LaTeX\
% compiler will be run to resolve cross-references, etc.
%
% * `'minRerun='` [ numeric | *`1`* ] - Minimum number of times the \LaTeX\
% compiler will be run to resolve cross-references, etc.
%
% * `'textScale='` [ numeric | *`0.8`* ] - Percentage of the total page
% area that will be used; the value can be either a scalar (the same
% percentage for the width and the height) or a 1-by-2 vector (the width
% and the height).
%
% Description
% ============
% 
% Difference between `'display='` and `'echo='`
% ----------------------------------------------
%
% There are two differences between these otherwise similar options:
%
% * When publishing the final PDF, the PDFLaTeX compiler may be called more
% than once to resolve cross-references, the table of contents, and so on.
% Setting `'display=' true` only displays the screen output from the final
% iteration only, while `'echo=' true` displays the screen outputs from all
% iterations.
%
% * In the case of a compiler error unrelated to the \LaTeX\ code, the
% compiler may stop and prompt the user to respond. The prompt only appears
% on the screen when `'echo=' true`. Otherwise, Matlab may remain in a busy
% state with no on-screen information, and `Ctrl+C` may be needed to regain
% control.
%
% Information struct
% -------------------
%
% The second output argument, `Info`, is a struct with details of building
% the PDF report. It contains the following fields:
%
% * `.latexRun` -- the total number of LaTeX compiler runs needed to
% resolve cross-references and other dependencies;
%
% * `.figureHandle` -- a vector of figure window handles created during the
% report production process, and not closed (i.e. still existing in the
% Matlab workspace); to keep figure windows open, use the figure object
% option `'close=' false`. If all `figure` and `userfigure` objects inside
% a report have `'close=' true` then `Info.figureHandle` will be empty.
%
% * `.tempDir` -- empty unless `publish` is called with `'cleanup=' false`;
% in that case, this is the name of a temporary directory in which all
% files are saved necessary to build the output PDF are saved.
%
% * `.tempFile` -- empty unless `publish` is called with `'cleanup='
% false`; in that case, this is the list of all files (saved in the
% temporary directory) necessary to build the output PDF.
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.
