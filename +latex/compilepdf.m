function [pdf, count] = compilepdf(inpFile, varargin)
% compilepdf  Publish latex file to PDF.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

opt = passvalopt('latex.compilepdf', varargin{:});

%--------------------------------------------------------------------------

config = iris.get( );
if isempty(config.PdfLaTeXPath)
    utils.error('latex:compilepdf',...
        'PDF LaTeX engine path unknown. Cannot compile PDF files.');
end

[inpPath, inpTitle] = fileparts(inpFile);

% TODO: We need to verify that all pdflatex distributions support the
% option `-halt-on-error`.
haltOnError = '-halt-on-error ';

systemOpt = { };
if opt.echo
    opt.display = false;
    systemOpt = {'-echo'};
end

command = [ ...
    '"', config.PdfLaTeXPath, '" ', ...
    haltOnError, ...
    inpTitle, ...
    ];

% Capture the current directory, and switch to the input file directory.
thisDir = pwd( );
if ~isempty(inpPath)
    cd(inpPath);
end

count = 0;
while true
    count = count + 1;
    [status, result] = system(command, systemOpt{:});
    if count<opt.minrerun
        continue
    elseif count>opt.maxrerun
        break
    end
    needsRerun = rerunTest(result,inpTitle);
    if status==0 && ~needsRerun
        break
    end
end

% Return back to the original directory.
cd(thisDir);

if opt.display || status~=0
    disp(result);
end

pdf = fullfile(inpPath, [inpTitle, '.pdf']);
fprintf('\n');
end




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
end
