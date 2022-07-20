function inclGraph = mycompilepdf(this, opt)
% mycompilepdf  Publish figure to PDF.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

set(this.handle, 'PaperType', this.options.papertype);

% Set orientation, rotation, and raise box.
if (all(strcmpi(opt.orientation, 'landscape')) && ~this.options.sideways) ...
        || (all(strcmpi(opt.orientation, 'portrait')) && this.options.sideways)
    orient(this.handle, 'landscape');
    angle = 0;
    raise = 10;
else
    orient(this.handle, 'tall');
    angle = 0;
    raise = 0;
end

% Fill in the entire page.
paperSize = get(this.handle, 'PaperSize');
set(this.handle, 'PaperPosition', [0, 0, paperSize]);

% Print figure to PDF.
pdfName = '';
pdfTitle = '';
printFigure( );

if strcmpi(this.options.figurescale, 'auto')
    switch class(this.parent)
        case 'report.reportobj'
            if validate.anyString(this.options.papertype, "usletter", "uslegal")
                this.options.figurescale = 0.8;
            else
                this.options.figurescale = 0.85;
            end
        case 'report.alignobj'
            this.options.figurescale = 0.3;
        otherwise
            this.options.figurescale = 1;
    end
end

trim = this.options.figuretrim;
if length(trim) == 1
    trim = trim*[1, 1, 1, 1];
end

this.hInfo.package.graphicx = true;
inclGraph = [ ...
    '\raisebox{', sprintf('%gpt', raise), '}{', ...
    '\includegraphics', ...
    sprintf('[scale=%g, angle=%g, trim=%gpt %gpt %gpt %gpt, clip=true]{%s}', ...
    this.options.figurescale, angle, trim, pdfTitle), ...
    '}'];

return




    function printFigure( )
        tempDir = this.hInfo.tempDir;
        h = this.handle;
        % Create graphics file path and title.
        if isempty(this.options.saveas)
            pdfName = tempname(tempDir);
            [~, pdfTitle] = fileparts(pdfName);
        else
            [saveAsPath, saveAsTitle] = fileparts(this.options.saveas);
            pdfName = fullfile(tempDir, saveAsTitle);
            pdfTitle = saveAsTitle;
        end
        
        % Apply user aspect ratio to all axes objects except legends.
        setAspectRatio( );
        
        % Print the figure window to PDF.
        try
            p = get(h, 'PaperSize');
            set(h, 'PaperPosition', [0, 0, p]);
            print(h, '-dpdf', '-painters', pdfName);
            addtempfile(this, [pdfName, '.pdf']);
        catch Err
            utils.error('report:mycompilepdf', ...
                ['Cannot print figure #%g to PDF: %s.\n', ...
                '\tUncle says: %s'], ...
                double(h), pdfName, Err.message);
        end

        % Save under the temporary name (which will be referred to in
        % the tex file) in the current or user-supplied directory.
        if ~isempty(this.options.saveas)
            % Use try-end because the temporary directory can be the same
            % as the current working directory, in which case `copyfile`
            % throws an error (Cannot copy or move a file or directory onto
            % itself).
            try %#ok<TRYNC>
                copyfile([pdfName, '.pdf'], ...
                    fullfile(saveAsPath, [pdfTitle, '.pdf']));
            end
        end
    end 




    function setAspectRatio( )
        if isequal(this.options.aspectratio, @auto)
            return
        end
        ch = get(this.handle, 'children');
        for i = ch(:).'
            if all(strcmpi(get(i, 'tag'), 'legend')) ...
                    || ~all(strcmpi(get(i, 'type'), 'axes'))
                continue
            end
            try %#ok<TRYNC>
                set(i, 'PlotBoxAspectRatio', ...
                    [this.options.aspectratio(:).', 1]);
            end
        end
    end 
end
