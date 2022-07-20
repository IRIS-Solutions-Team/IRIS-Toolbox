function [outputFileName, infoStruct] = publish(this, outputFileName, varargin)
% publish  Help provided in +report/publish.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

% The following options passed down to latex.compilepdf:
% * `'cd='` (obsolete)
% * `'display='`
% * `'rerun='`
% and we need to capture them in output varargin.

persistent parser
if isempty(parser)
    parser = extend.InputParser('report.publish');
    parser.KeepUnmatched = true;
    parser.addRequired('Report', @(x) isa(x, 'report.reportobj'));
    parser.addRequired('OutputFileName', @validate.string);
    parser.addParameter('Encoding', @auto, @(x) isequal(x, @auto) || validate.string(x));
    parser.addParameter('abstract', '', @(x) isempty(x) || ischar(x));
    parser.addParameter('abstractwidth', '', @(x) validate.numericScalar(x) && x>0 && x<=1);
    parser.addParameter('author', '', @ischar);
    parser.addParameter({'cleanup', 'deletelatex', 'deletetempfiles'}, true, @validate.logicalScalar);
    parser.addParameter('compile', true, @validate.logicalScalar);
    parser.addParameter('date', '\today', @ischar);
    parser.addParameter('epstopdf', Inf, @(x) isequal(x, Inf) || ischar(x));
    parser.addParameter('fontenc', 'T1', @ischar);
    parser.addParameter('maketitle', false, @validate.logicalScalar);
    parser.addParameter('papersize', 'letterpaper', @(x) validate.anyString(x, 'a4', 'a4paper', 'letter', 'letterpaper')); 
    parser.addParameter('package', { }, @(x) ischar(x) || iscellstr(x) || isempty(x));
    parser.addParameter('preamble', '', @ischar);
    parser.addParameter('progress', false, @validate.logicalScalar);
    parser.addParameter('title', Inf, @(x) ischar(x) || isequal(x, Inf));
    parser.addParameter('timestamp', @( ) datestr(now( )), @(x) ischar(x) || isa(x, 'function_handle'));
    parser.addParameter({'textscale', 'scale'}, 0.8, @(x) isnumeric(x) && (length(x) == 1 || length(x) == 2));
    parser.addParameter('tempdir', @( ) tempname(pwd( )), @(x) isa(x, 'function_handle') || ischar(x));
end
parse(parser, this, outputFileName, varargin{:});
opt = parser.Options;
compilePdfOpt = parser.UnmatchedInCell;
this.options.progress = opt.progress;

if isempty(strfind(opt.papersize, 'paper'))
    opt.papersize = [opt.papersize, 'paper'];
end

if ~isequal(opt.title, Inf)
    this.caption = opt.title;
end

this.options = dbmerge(this.options, opt);

%--------------------------------------------------------------------------

% Create the temporary directory.
doCreateTempDir( );

thisDir = fileparts(mfilename('fullpath'));
templateFile = fullfile(thisDir, 'report.tex');

% Pass the publish options on to the report object and align objects
% either of which can be a parent of figure.
c = file2char(templateFile);

% Create LaTeX code for the entire report.
doc = latexcode(this);

% Get the list of extra packages that needs to be loaded by LaTeX.
pkg = { };
doExtraPkg( );

% Insert the LaTeX code into the template.
c = strrep(c, '$document$', doc);

% Document substitutions.
c = report.reportobj.insertDocSubstitutions(this, c, pkg);

% Create a temporary tex name and save the LaTeX file.
latexFile = '';
doSaveLatexFile( );

[outputPath, outputTitle, outputExt] = fileparts(outputFileName);
if isempty(outputExt)
    outputFileName = fullfile(outputPath, [outputTitle, '.pdf']);
end

if opt.compile
    doCompile( );
end

[latexPath, latexTitle] = fileparts(latexFile);
addtempfile(this, fullfile(latexPath, [latexTitle, '.*']));

if opt.cleanup
    cleanup(this);
end

% Copy output information fields to a struct
infoStruct = outpstruct(this.hInfo);

return




    function doExtraPkg( )
        pkg = opt.package;
        if ischar(pkg)
            pkg = regexp(pkg, '\w+', 'match');
        end
        list = fieldnames(this.hInfo.package);
        for i = 1 : length(list)
            name = list{i};
            if this.hInfo.package.(name)
                pkg{end+1} = name; %#ok<AGROW>
            end
        end
    end




    function doCreateTempDir( )
        % Assign the temporary directory name property.
        if isa(opt.tempdir, 'function_handle')
            tempDir = opt.tempdir( );
        else
            tempDir = opt.tempdir;
        end
        % Try to create the temp dir.
        if exist(tempDir, 'dir')~=7
            status = mkdir(tempDir);
            if ~status
                utils.error('report', ...
                    'Cannot create temporary directory ''%s''.', ...
                    tempDir);
            end
        end
        this.hInfo.tempDir = tempDir;
    end




    function doSaveLatexFile( )
        tempDir = this.hInfo.tempDir;
        latexFile = [tempname(tempDir), '.tex'];
        textual.write(c, latexFile, 'char', 'Encoding', opt.Encoding);
    end



    function doCompile( )
        % Use try-catch to make sure the helper files are deleted at the
        % end of `publish`.
        try
            [pdfName, count] = latex.compilepdf(latexFile, compilePdfOpt{:});
            this.hInfo.latexRun = count;
            movefile(pdfName, outputFileName);
        catch Error
            msg = regexprep(Error.message, '\s+', ' ');
            if ~isempty(strfind(msg, 'The process cannot access'))
                cleanup(this);
                utils.error('report', ...
                    ['Cannot create ''%s'' file because ', ...
                    'the file used by another process ', ...
                    '-- most likely open and locked.'], ...
                    outputFileName);
            else
                utils.warning('report', ...
                    ['Error compiling LaTeX and/or PDF files.\n', ...
                    '\tUncle says: %s'], ...
                    msg);
            end
        end
    end
end
