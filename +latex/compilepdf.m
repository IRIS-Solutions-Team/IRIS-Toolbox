function [pdf, count] = compilepdf(inpFile, varargin)
% compilepdf  Publish latex file to PDF
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('latex.compilepdf');
    parser.addRequired('InputFileName', @(x) ischar(x) || isa(x, 'string'));
    parser.addParameter('Cd', false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('Display', true, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('Echo', false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('MaxRerun', 5, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>=0);
    parser.addParameter('MinRerun', 1, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>=0);
end
parser.parse(inpFile, varargin{:});
opt = parser.Options;

%--------------------------------------------------------------------------

config = iris.get( );
if isempty(config.PdfLaTeXPath)
    THIS_ERROR = { 'Latex:PDFEngineUnknown' 
                   'LaTeX engine path unknown. Cannot compile PDF files.' };
    throw( exception.Base(THIS_ERROR, 'error') );
end

[inpPath, inpTitle, inpExt] = fileparts(inpFile);

% TODO: We need to verify that all pdflatex distributions support the
% option `-halt-on-error`.
haltOnError = '-halt-on-error ';

systemOpt = { };
if opt.Echo
    opt.Display = false;
    systemOpt = {'-echo'};
end

command = ['"', config.PdfLatexPath, '" ',  haltOnError, ' "', inpTitle, '"'];

% Capture the current directory, and switch to the input file directory
thisDir = pwd( );
if ~isempty(inpPath)
    cd(inpPath);
end

count = 0;
while true
    count = count + 1;
    [status, result] = system(command, systemOpt{:});
    if count<opt.MinRerun
        continue
    elseif count>opt.MaxRerun
        break
    end
    needsRerun = rerunTest(result,inpTitle);
    if status==0 && ~needsRerun
        break
    end
end

% Return back to the original directory
cd(thisDir);

if opt.Display || status~=0
    disp(result);
end

pdf = fullfile(inpPath, [inpTitle, '.pdf']);
fprintf('\n');

end%


function needsRerun = rerunTest(result, fileTitle)
    % xxRerunTest  Search in the screen message and the log file for hints
    % indicating a need to rerun the compiler.
    FN_FIND = @(A,B) ~isempty(strfind(A,B));
    % Search in output screen message for hints.
    needsRerun = FN_FIND(result, 'Rerun') ...
            || FN_FIND(result, 'undefined references') ...
            || ~isempty(regexp(result, 'No file \w+\.toc','once'));

    % Search the log file for hints.
    try %#ok<TRYNC>
        c = file2char([fileTitle, '.log']);
        needsRerun = needsRerun || FN_FIND(c, 'Rerun');
    end
end%

