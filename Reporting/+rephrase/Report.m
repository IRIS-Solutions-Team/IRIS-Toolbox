classdef Report ...
    < rephrase.Container

    properties % (Constant)
        Type = string(rephrase.Type.REPORT)
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
            string(rephrase.Type.CHART)
            string(rephrase.Type.CURVECHART)
            string(rephrase.Type.GRID)
            string(rephrase.Type.MATRIX)
            string(rephrase.Type.PAGEBREAK)
            string(rephrase.Type.PAGER)
            string(rephrase.Type.SECTION)
            string(rephrase.Type.SERIESCHART)
            string(rephrase.Type.TABLE)
            string(rephrase.Type.TEXT)
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
            %(
            persistent ip
            if isempty(ip)
                ip = inputParser();
                addParameter(ip, 'SaveJson', false, @validate.logicalScalar);
                addParameter(ip, 'Source', "local", @(x) isstring(x) && ~isempty(x) && all(ismember(lower(reshape(x, 1, [ ])), lower(["local", "bundle", "web"]))));
                addParameter(ip, 'Template', []);
                addParameter(ip, 'UserStyle', "", @(x) (isstring(x) || ischar(x)) && (isscalar(string(x))));
                addParameter(ip, 'Context', struct());
                addParameter(ip, 'ColorScheme', "");
            end
            parse(ip, varargin{:});
            opt = ip.Results;
            %)

            fileNameBase = here_resolveFileNameBase(fileName);

            %
            % Finalize report elements
            % * Finalize data
            % * Assign IDs
            %
            counter = rephrase.Counter();
            finalize(this, counter);


            %
            % Create report json
            %

            reportJson = string(jsonencode(this));
            reportJson = local_substituteParameters(reportJson, opt.Context);

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

            colorSchemeJson = local_readColorScheme(opt.ColorScheme);

            script = join([
                "var $report=" + reportJson + ";"
                "var $databank=" + dataJson + ";"
                "var $colorScheme=" + colorSchemeJson + ";"
            ], string(newline()));

            outputFileNames = string.empty(1, 0);
            for source = reshape(lower(opt.Source), 1, [ ])
                if isempty(opt.Template)
                    template = here_readTemplate(source);
                else
                    template = local_readTextFile(opt.Template);
                end

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
                    templateFolder = fullfile(iris.root(), "Reporting", ".rephrase");
                    switch source
                        case "bundle"
                            templateFileName = fullfile(templateFolder, "report-template.bundle.html");
                            template = local_readTextFile(templateFileName);
                        case "local"
                            templateFileName = fullfile(templateFolder, "report-template.html");
                            template = local_readTextFile(templateFileName);
                            template = replace(template, """lib/", """" + fullfile(iris.root(), "Reporting", ".rephrase", "lib/"));
                            template = replace(template, """img/", """" + fullfile(iris.root(), "Reporting", ".rephrase", "img/"));
                        case "web"
                            templateFileName = fullfile(templateFolder, "report-template-web-source.html");
                            template = local_readTextFile(templateFileName);
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


function reportJson = local_substituteParameters(reportJson, context)
    %(
    fields = databank.fieldNames(context);
    if isempty(fields)
        return
    end
    values = string.empty(1, 0);
    for n = fields
        values(1, end+1) = string(context.(n));
    end
    reportJson = replace(reportJson, "$("+fields+")", values);
    %)
end%


function colorSchemeJson = local_readColorScheme(filename)
    %(
    if isempty(filename) || strlength(filename)==0
        colorSchemeJson = "{}";
        return
    end
    colorSchemeJson =  jsonencode(jsondecode(fileread(filename)));
    %)
end%

