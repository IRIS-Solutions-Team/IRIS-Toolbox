function publish(inpFile, varargin)
% publish  Publish m-file or model file to PDF.
%
%
% __Syntax__
%
%     latex.publish(InpFile)
%     latex.publish(InpFile,...)
%
%
% __Input Arguments__
%
% * `InpFile` [ char | cellstr ] - Input file name; can be either an
% m-file, a model file, or a cellstr combining a number of them.
%
%
% __Options__
%
%
% _General Options_
%
% * `'Cleanup='` [ *`true`* | `false` ] - Delete all temporary files
% (LaTeX and eps) at the end.
%
% * `'CloseAll='` [ *`true`* | `false` ] - Close all figure windows at the
% end.
%
% * `'Display='` [ *`true`* | `false` ] - Display pdflatex compiler report.
%
% * `'EvalCode='` [ *`true`* | `false` ] - Evaluate code when publishing the
% file; the option is only available with m-files.
%
% * `'UseNewFigure='` [ `true` | *`false`* ] - Open a new figure window for each
% graph plotted.
%
%
% _Content Related Options_
%
% * `'Author='` [ char | *empty* ] - Author that will be included on the
% title page.
%
% * `'Date='` [ char | *'\today' ] - Publication date that will be included
% on the title page.
%
% * `'Event='` [ char | *empty* ] - Event (conference, workshop) that will
% be included on the title page.
%
% * `'FigureFrame='` [ `true` | *`false`* ] - Draw frames around figures.
%
% * `'FigureScale='` [ numeric | *`1`* ] - Factor by which the graphics
% will be scaled.
%
% * `'FigureTrim='` [ numeric | *`[50,200,50,150]`* ] - Trim excessive
% white margines around figures by the specified amount of points left,
% bottom, right, top.
%
% * `'IrisVersion='` [ *`true`* | `false` ] - Display the current IRIS version
% in the header on the title page.
%
% * `'LineSpread='` [ numeric | *'auto'*] - Line spacing.
%
% * `'MatlabVersion='` - Display the current Matlab version in the header on
% the title page.
%
% * `'Numbered='` - [ *`true`* | `false` ] - Number sections.
%
% * `'Package='` - [ cellstr | char | *`'inconsolata'`* ] - List of
% packages that will be loaded in the preamble.
%
% * `'PaperSize='` -  [ 'a4paper' | *'letterpaper'* ] - Paper size.
%
% * `'Preamble='` - [ char | *empty* ] - LaTeX commands
% that will be included in the preamble of the document.
%
% * `'Template='` - [ *'paper'* | 'present' ] - Paper-like or
% presentation-like format.
%
% * `'TextScale='` - [ numeric | *0.70* ] - Proportion of the paper used for
% the text body.
%
% * `'Toc='` - [ *`true`* | `false` ] - Include the table of contents.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

% Bkw compatibility.
if ~isempty(varargin) && isempty(varargin{1})
    varargin(1) = [ ];
end

isnumericscalar = @(x) isnumeric(x) && isscalar(x);
islogicalscalar = @(x) islogical(x) && isscalar(x);

%(
defaults = { 
    'author', '', @ischar
    'cleanup', true, @(x) isequal(x, true) || isequal(x, false)
    'closeall', true, @(x) isequal(x, true) || isequal(x, false)
    'date', '\today', @ischar
    'cleanup', [ ], @(x) isempty(x) || islogicalscalar(x)
    'display', true, @(x) isequal(x, true) || isequal(x, false)
    'evalcode', true, @(x) isequal(x, true) || isequal(x, false)
    'event', '', @ischar
    'figureframe', false, @(x) isequal(x, true) || isequal(x, false)
    'figurescale', 0.75, @(x) isnumericscalar(x) && x>0
    'figuretrim', [50, 210, 50, 180], @(x) isnumeric(x) && numel(x)==4
    'figurewidth', '4in', @ischar
    'irisversion', true, @(x) isequal(x, true) || isequal(x, false)
    'linespread', 'auto', @(x) (ischar(x) && strcmpi(x, 'auto')) || isnumericscalar(x) && x>0
    'matlabversion', true, @(x) isequal(x, true) || isequal(x, false)
    'numbered', true, @(x) isequal(x, true) || isequal(x, false)
    'papersize', 'letterpaper', @(x) all(strcmpi(x, 'a4paper')) || all(strcmpi(x, 'letterpaper'))
    'preamble', '', @ischar
    'package', { }, @(x) iscellstr(x) || ischar(x) || isempty(x)
    'supertitle', '', @(x) isempty(x) || ischar(x)
    'template', 'paper', @(x) ischar(x) && any(strcmpi(x, {'paper', 'present'}))
    'textscale', 0.70, isnumericscalar
    'toc', true, @(x) isequal(x, true) || isequal(x, false)
    'usenewfigure', false, @(x) isequal(x, true) || isequal(x, false)
};
%)


opt = passvalopt(defaults, varargin{:});


if opt.toc && ~opt.numbered
    utils.error('latex', ...
        'Options ''numbered'' and ''toc'' are used inconsistently.');
end

[inpPath, inpTitle, inpExt] = fileparts(inpFile);
texFile = [inpTitle, '.tex'];
outpFile = fullfile(inpPath, [inpTitle, '.pdf']);
if isempty(inpExt)
    inpExt = '.m';
end
canEvalCode = strcmp(inpExt, '.m');
rptFileName = [inpTitle, inpExt];

%--------------------------------------------------------------------------

br = sprintf('\n');

if strcmpi(opt.template, 'paper')
    template = file2char(fullfile(iris.root( ), '+latex', 'paper.tex'));
    if ~isnumericscalar(opt.linespread)
        opt.linespread = 1.1;
    end
else
    template = file2char(opt.template);
    if ~isnumericscalar(opt.linespread)
        opt.linespread = 1;
    end
end
template = textual.convertEndOfLines(template);

thisDir = pwd( );
wDir = tempname(thisDir);
mkdir(wDir);

% Run input files with compact spacing.
spacing = get(0, 'formatSpacing');
set(0, 'formatSpacing', 'compact');

% Create mfile2xml (publish) options. The output directory is assumed to
% always coincide with the input file directory.
m2xmlOpt = struct( ...
    'format','xml', ...
    'outputDir',wDir, ...
    'imageFormat','pdf', ...
    'figureSnapMethod','print', ...
    'createThumbnail',false, ...
    'evalCode',opt.evalcode, ...
    'useNewFigure',opt.usenewfigure);

% Try to copy all tex files to the working directory in case there are
% \input or \include commands.
try %#ok<TRYNC>
    copyfile('*.tex', wDir);
end

needsTempFile = ~all(strcmpi(inpExt, '.m'));
if needsTempFile
    tempFileName = [tempname(pwd( )), '.m'];
    copyfile([inpTitle,inpExt], tempFileName);
    [~, inpTitle, inpExt] = fileparts(tempFileName);
end

% Produce XMLDOM
%----------------
copy = prepareToPublish([inpTitle, inpExt]);

% Only m-files can be published with `'evalCode='` true.
m2xmlOpt.evalCode = canEvalCode && opt.evalcode;

% Switch off warnings produced by the built-in publish when conversion
% of latex equations to images fails.
ss = warning( );
warning('off');%#ok<WNOFF>
% Publish the m-file into an xml file and read the file in again as xml
% object.
xmlFile = publish([inpTitle, inpExt], m2xmlOpt);
warning(ss);
xmlDoc = xmlread(xmlFile);
textual.write(copy, [inpTitle, inpExt]);

% Reset spacing.
set(0, 'formatSpacing', spacing);

% Switch to the working directory so that `xml2tex` can find the graphics
% files.
cd(wDir);
try
    body = '';
    [tex, author, event] = latex.xml.xml2tex(xmlDoc, opt);
    if isempty(opt.author) && ischar(author)
        opt.author = author;
    end
    if isempty(opt.author) && ischar(event)
        opt.event = event;
    end
    tex = expandDocSubs(tex, rptFileName, opt);
    textual.write(tex,texFile);
    body = [body, '\input{', texFile, '}', br];
    
    template = strrep(template, '$body$', body);
    template = expandDocSubs(template, rptFileName, opt);
    
    textual.write(template, 'main.tex');
    latex.compilepdf('main.tex');
    copyfile('main.pdf', outpFile);
    movefile(outpFile, thisDir);
catch Err
    utils.warning('latex:publish', ...
        ['Error producing PDF.\n', ...
        '\tUncle says: %s'], ...
        Err.message);
end

cd(thisDir);
if opt.cleanup
    rmdir(wDir, 's');
end

if opt.closeall
    close('all');
end

if needsTempFile
    delete(tempFileName);
end

end




function c = expandDocSubs(c, rptFileName, opt)
BR = sprintf('\n');
c = strrep(c,'$papersize$', opt.papersize);

% Author.
opt.author = strtrim(opt.author);
if ischar(opt.author) && ~isempty(opt.author)
    c = strrep(c, '$author$', ['\byauthor ', opt.author]);
elseif ischar(opt.event) && ~isempty(opt.event)
    c = strrep(c, '$author$', ['\atevent ', opt.event]);
else
    c = strrep(c,'$author$','');
end

c = strrep(c, '$date$', opt.date);
c = strrep(c, '$textscale$', sprintf('%g', opt.textscale));

% Figures.
c = strrep(c,'$figurescale$', sprintf('%g', opt.figurescale));
c = strrep(c,'$figuretrim$', sprintf('%gpt ', opt.figuretrim));
if opt.figureframe
    c = strrep(c,'$figureframe$','\fbox');
else
    c = strrep(c,'$figureframe$','');
end

% Matlab and IRIS versions.
if opt.matlabversion
    v = version( );
    v = strrep(v,' ','');
    v = regexprep(v,'(.*)\s*\((.*?)\)','$2');
    c = strrep(c,'$matlabversion$', ...
        ['Matlab: ',v]);
else
    c = strrep(c,'$matlabversion$','');
end
if opt.irisversion
    c = strrep(c,'$irisversion$', ...
        ['[IrisToolbox]: ',iris.get('Release')]);
else
    c = strrep(c,'$irisversion$','');
end

% Packages.
if ~isempty(opt.package)
    c1 = '';
    if ischar(opt.package)
        opt.package = {opt.package};
    end
    npkg = length(opt.package);
    for i = 1 : npkg
        pkg = opt.package{i};
        if isempty(strfind(pkg,'{'))
            c1 = [c1,'\usepackage{',pkg,'}']; %#ok<AGROW>
        else
            c1 = [c1,'\usepackage',pkg]; %#ok<AGROW>
        end
        c1 = [c1,BR]; %#ok<AGROW>
    end
    c = strrep(c,'$packages$',c1);
else
    c = strrep(c,'$packages$','');
end

c = strrep(c,'$preamble$',opt.preamble);
if opt.numbered
    c = strrep(c,'$numbered$','');
else
    c = strrep(c,'$numbered$','*');
end
linespread = sprintf('%g',opt.linespread);
c = strrep(c, '$linespread$', linespread);

rptFileName = latex.replaceSpecChar(rptFileName);
c = strrep(c, '$filename$', rptFileName);
end 




function copy = prepareToPublish(file)
% xxpreparetopublish  Remove formats not recognised by built-in publish.
    c = file2char(file);
    copy = c;
    % Replace %... and %%% with %% ...
    c = regexprep(c, '^%[ \t]*\.\.\.\s*$', '%% ...','lineanchors');
    c = regexprep(c, '^%%%[ \t]*(?=\n)$', '%% ...','lineanchors');
    % Remove underlines % ==== with 4+ equal signs.
    c = regexprep(c, '^% ?====+','%','lineanchors');
    % Remove underlines % ---- with 4+ equal signs.
    c = regexprep(c, '^% ?----+','%','lineanchors');
    % Replace ` with |.
    c = strrep(c, '`', '|');
    textual.write(c, file);
end
