function [outputFileName, infoStruct] = publish(this, outputFileName, varargin)
% publish  Help provided in +report/publish.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

% The following options passed down to latex.compilepdf:
% * `'cd='` (obsolete)
% * `'display='`
% * `'rerun='`
% and we need to capture them in output varargin.
[opt, compilePdfOpt] = passvalopt('report.publish', varargin{:});
this.options.progress = opt.progress;

if isempty(strfind(opt.papersize, 'paper'))
    opt.papersize = [opt.papersize, 'paper'];
end

if ~isequal(opt.title, Inf)
    utils.warning('report', ...
        ['The option ''title='' is obsolete in report/publish( ), ', ...
        'and will be removed from future versions of IRIS. ', ...
        'Use the Caption input argument in report/new( ) instead.']);
    this.caption = opt.title;
end

% Obsolete options.
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
        pkg = this.options.package;
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
        if isfunc(opt.tempdir)
            tempDir = opt.tempdir( );
        else
            tempDir = opt.tempdir;
        end
        % Try to create the temp dir.
        if ~utils.exist(tempDir)
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
        char2file(c, latexFile);
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
