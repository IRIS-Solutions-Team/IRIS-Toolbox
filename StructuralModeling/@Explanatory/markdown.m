
function md = markdown(this, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addParameter(ip, "FileName", "");
end
parse(ip, varargin{:});
opt = ip.Results;

    n = numel(this);

    md = cell(1, n);
    for i = 1:numel(this)
        md{i} = local_markdown(this(i), opt);
    end

end%


function md = local_markdown(this, opt)
    %(
    md = string.empty(1, 0);

    stdErrors = sqrt(diag(this.Statistics.CovParameters));
    periodsFitted = join(dater.toDefaultString(this.Statistics.PeriodsFitted{1}), " ");

    md = [md, sprintf("## Equation for `%s`", this.LhsName), "", ""];
    md = [md, "* Type of equation: " + local_getType(this), "", ""];
    md = [md, "* Specification: `" + this.InputString + "`", "", ""];
    md = [md, "* Number of periods fitted: " + periodsFitted, "", ""];
    md = [md, "* Periods fitted: " + string(this.Range), "", ""];
    md = [md, "Parameter# | Estimate | Std. Error", ":-----------|---------:|------------:"];
    for i = 1 : numel(this.Parameters)
        md = [md, sprintf("%g | %g | %g", i, this.Parameters(i), stdErrors(i))]
    end
    md = [md, ""];

    md = join(md, newline());
    %)
end%


function type = local_getType(this)
    %(
    if this.IsIdentity
        type = "Identity";
        return
    end

    type = sprintf("Regression with %g parameters", this.NumParameters);

    if ~isempty(this.ResidualModel)
        residualModel = "plain"
    else
        residualModel = "ARMA";
    end

    type = [type, sprintf(" and %s residuals", residualModel)];
    %)
end%


