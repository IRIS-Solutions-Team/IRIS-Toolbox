classdef Report ...
    < rephrase.Element ...
    & rephrase.Container

    properties (Constant)
        Type = rephrase.Type.REPORT
    end


    properties (Constant, Hidden)
        PossibleChildren = [
            rephrase.Type.GRID
            rephrase.Type.TABLE
            rephrase.Type.CHART
            rephrase.Type.TEXT
            rephrase.Type.PAGEBREAK
            rephrase.Type.MATRIX
        ]
        EMBED_REPORT_DATA = "// report-data-script-here"
    end


    methods
        function this = Report(title, varargin)
            this = this@rephrase.Element(title, varargin{:});
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
            end
            %)
            opt = parse(pp, this, fileName, reportDb, varargin{:});

            fileNameBase = hereResolveFileNameBase(fileName);

            build@rephrase.Container(this);
            reportJson = string(jsonencode(this));
            if isempty(this.DataRequests) || isempty(keys(reportDb))
                dataJson = string(jsonencode(cell.empty(1, 0)));
            else
                requestDb = databank.copy(reportDb, "SourceNames=", this.DataRequests);
                serial = series.Serialize( );
                dataJson = string(jsonencode(serial.jsonFromDatabank(requestDb)));
            end
            script = ...
                "var $report=" + reportJson + ";" + string(newline( )) ...
                + "var $databank=" + dataJson + ";" ...
            ;

            outputFileNames = string.empty(1, 0);
            for source = reshape(lower(opt.Source), 1, [ ])
                template = hereReadTemplate(source);
                hereEmbedReportData( );
                outputFileNames(end+1) = hereWriteFinalHtml( ); %#ok<*AGROW>
            end

            return

                function fileNameBase = hereResolveFileNameBase(fileName)
                    %(
                    [p, t, ~] = fileparts(fileName);
                    fileNameBase = fullfile(string(p), string(t));
                    %)
                end%


                function template = hereReadTemplate(source)
                    %(
                    templateFolder = fullfile(iris.root( ), "Plugins", ".rephrase");
                    switch source
                        case "bundle"
                            templateFileName = fullfile(templateFolder, "report-template.bundle.html");
                            template = locallyReadTextFile(templateFileName);
                        case "local"
                            templateFileName = fullfile(templateFolder, "report-template.html");
                            template = locallyReadTextFile(templateFileName);
                            template = replace(template, """lib/", """" + fullfile(iris.root( ), "Plugins", ".rephrase", "lib/"));
                            template = replace(template, """img/", """" + fullfile(iris.root( ), "Plugins", ".rephrase", "img/"));
                        case "web"
                            templateFileName = fullfile(templateFolder, "report-template-web-source.html");
                            template = locallyReadTextFile(templateFileName);
                        otherwise
                            % TODO: Throw error
                    end
                    %)
                end%


                function hereEmbedReportData( )
                    %(
                    template = replace( ...
                        template, this.EMBED_REPORT_DATA, script ...
                    );
                    %)
                end%


                function outputFileName = hereWriteFinalHtml( )
                    %(
                    outputFileName = fileNameBase + "." + source + ".html";
                    locallyWriteTextFile(outputFileName, template);
                    if opt.SaveJson
                        locallyWriteTextFile(fileNameBase+"."+source+".report.json", reportJson);
                        locallyWriteTextFile(fileNameBase+"."+source+".data.json", dataJson);
                    end
                    %)
                end%
        end%
    end
end 

%
% Local Functions
%

function content = locallyReadTextFile(fileName)
    %(
    fid = fopen(fileName, "rt+", "native", "UTF-8");
    content = fread(fid, Inf, "*char", "native");
    fclose(fid);
    content = string(reshape(content, 1, [ ]));
    %)
end%


function locallyWriteTextFile(fileName, content)
    %(
    fid = fopen(fileName, "wt+", "native", "UTF-8");
    fwrite(fid, content, "*char");
    fclose(fid);
    %)
end%

