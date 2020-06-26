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
            rephrase.Type.DIFFTABLE
            rephrase.Type.CHART
            rephrase.Type.TEXT
            rephrase.Type.PAGEBREAK
        ]
    end


    methods
        function this = Report(title, varargin)
            this = this@rephrase.Element(title, varargin{:});
            this.Content = cell.empty(1, 0);
        end%


        function build(this, fileName, reportDb, varargin)
            %( Input parser
            persistent pp
            if isempty(pp)
                pp = extend.InputParser('+rephrase/Report');
                addRequired(pp, 'report', @(x) isa(x, 'rephrase.Report'));
                addRequired(pp, 'fileName', @validate.string);
                addOptional(pp, 'reportDb', [ ], @(x) isempty(x) || validate.databank(x));
                addParameter(pp, 'SaveJson', false, @validate.logicalScalar);
            end
            %)
            opt = parse(pp, this, fileName, reportDb, varargin{:});
            build@rephrase.Container(this);
            reportJson = string(jsonencode(this));
            if isempty(this.DataRequests) || isempty(keys(reportDb))
                dataJson = string(jsonencode(cell.empty(1, 0)));
            else
                requestDb = databank.copy(reportDb, "SourceNames=", this.DataRequests);
                serial = series.Serialize( );
                dataJson = string(jsonencode(serial.encodeDatabank(requestDb)));
            end
            script = ...
                "var $report=" + reportJson + ";" + string(newline( )) ...
                + "var $databank=" + dataJson + ";" ...
            ;
            template = fileread("../report-template.html");
            template = replace(template, "// report-data-script-here", script);
            fid = fopen(fileName, "w+");
            fwrite(fid, template);
            fclose(fid);
            if opt.SaveJson
                fid = fopen(fileName+".json", "w+");
                fwrite(fid, reportJson);
                fclose(fid);
            end
        end%
    end
end 
