classdef Report ...
    < rephrase.Container

    properties % (Constant)
        Type = rephrase.Type.REPORT
    end


    properties (Hidden)
        Settings_Subtitle (1, 1) string = ""
        Settings_Footer (1, 1) string = ""
        Settings_InteractiveCharts (1, 1) logical = true
        Settings_TableOfContents (1, 1) logical = false
        Settings_TableOfContentsDepth (1, 1) double = 1
        Settings_Logo (1, 1) logical = false
    end


    properties (Constant, Hidden)
        PossibleChildren = [
            rephrase.Type.GRID
            rephrase.Type.TABLE
            rephrase.Type.CHART
            rephrase.Type.SERIESCHART
            rephrase.Type.CURVECHART
            rephrase.Type.TEXT
            rephrase.Type.PAGEBREAK
            rephrase.Type.MATRIX
            rephrase.Type.PAGER
            rephrase.Type.SECTION
        ]
        EMBED_REPORT_DATA = "// report-data-script-here"
        EMBED_USER_STYLE = "/* user-defined-css-here */"
    end


    methods
        function this = Report(title, varargin)
            this = this@rephrase.Container(title, varargin{:});
            this.Content = cell.empty(1, 0);
        end%


        function outputFileNames = build(this, fileName, reportDb, varargin)
            %( Input parser
            persistent pp
            if isempty(pp)
                pp = extend.InputParser('+rephrase/Report');
                addRequired(pp, 'report', @(x) isa(x, 'rephrase.Report'));
                addRequired(pp, 'fileName', @validate.stringScalar);
                addOptional(pp, 'reportDb', [ ], @(x) isempty(x) || validate.databank(x));

                addParameter(pp, 'SaveJson', false, @validate.logicalScalar);
                addParameter(pp, 'Source', "Local", @(x) isstring(x) && ~isempty(x) && all(ismember(lower(reshape(x, 1, [ ])), lower(["Local", "Bundle", "Web"]))));
                addParameter(pp, 'UserStyle', "", @(x) (isstring(x) || ischar(x)) && (isscalar(string(x))));
            end
            %)
            opt = parse(pp, this, fileName, reportDb, varargin{:});

            fileNameBase = here_resolveFileNameBase(fileName);

            %
            % Create report json
            %

            finalize(this);
            reportJson = string(jsonencode(this));

            %
            % Create data json
            %
            if isempty(this.DataRequests) || isempty(keys(reportDb))
                dataJson = string(jsonencode(cell.empty(1, 0)));
            else
                requestDb = databank.copy(reportDb, "sourceNames", this.DataRequests);
                serial = series.Serialize( );
                dataJson = string(jsonencode(serial.jsonFromDatabank(requestDb)));
            end

            script = ...
                "var $report=" + reportJson + ";" + string(newline( )) ...
                + "var $databank=" + dataJson + ";" ...
            ;

            outputFileNames = string.empty(1, 0);
            for source = reshape(lower(opt.Source), 1, [ ])
                template = here_readTemplate(source);

                % FIXME
                % template = replace(template, """Lato""", """Open Sans""");

                template = here_embedReportData(template);
                template = here_embedUserStyle(template);
                outputFileNames(end+1) = here_writeFinalHtml( ); %#ok<*AGROW>
            end

            return

                function fileNameBase = here_resolveFileNameBase(fileName)
                    %(
                    [p, t, ~] = fileparts(fileName);
                    fileNameBase = fullfile(string(p), string(t));
                    %)
                end%


                function template = here_readTemplate(source)
                    %(
                    templateFolder = fullfile(iris.root( ), "Plugins", ".rephrase");
                    switch source
                        case "bundle"
                            templateFileName = fullfile(templateFolder, "report-template.bundle.html");
                            template = local_readTextFile(templateFileName);
                        case "local"
                            templateFileName = fullfile(templateFolder, "report-template.html");
                            template = local_readTextFile(templateFileName);
                            template = replace(template, """lib/", """" + fullfile(iris.root( ), "Plugins", ".rephrase", "lib/"));
                            template = replace(template, """img/", """" + fullfile(iris.root( ), "Plugins", ".rephrase", "img/"));
                        case "web"
                            templateFileName = fullfile(templateFolder, "report-template-web-source.html");
                            template = local_readTextFile(templateFileName);
                        otherwise
                            % TODO: Throw error
                    end
                    %)
                end%


                function template = here_embedReportData(template)
                    %(
                    template = replace( ...
                        template, this.EMBED_REPORT_DATA, script ...
                    );
                    %)
                end%


                function template = here_embedUserStyle(template)
                    %(
                    if strlength(opt.UserStyle)==0
                        return
                    end
                    code = fileread(opt.UserStyle);
                    template = replace(template, this.EMBED_USER_STYLE, code);
                    %)
                end%


                function outputFileName = here_writeFinalHtml( )
                    %(
                    outputFileName = fileNameBase + "." + source + ".html";
                    local_writeTextFile(outputFileName, template);
                    if opt.SaveJson
                        local_writeTextFile(fileNameBase+"."+source+".report.json", reportJson);
                        local_writeTextFile(fileNameBase+"."+source+".data.json", dataJson);
                    end
                    %)
                end%
        end%
    end
end 

%
% Local Functions
%

function content = local_readTextFile(fileName)
    %(
    fid = fopen(fileName, "rt+", "native", "UTF-8");
    content = fread(fid, Inf, "*char", "native");
    fclose(fid);
    content = string(reshape(content, 1, [ ]));
    %)
end%


function local_writeTextFile(fileName, content)
    %(
    fid = fopen(fileName, "wt+", "native", "UTF-8");
    if fid<0
        exception.error([
            "Rephrase"
            "Cannot open this file for writing: %s"
        ], fileName);
    end
    try
        fwrite(fid, content, "*char");
    catch mexp
        fclose(fid);
        rethrow(mexp)
    end
    fclose(fid);
    %)
end%

