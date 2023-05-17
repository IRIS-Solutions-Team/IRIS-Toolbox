
function md = markdown(this, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addParameter(ip, "FileName", "");
    addParameter(ip, "Heading", "#");
end
parse(ip, varargin{:});
opt = ip.Results;

    n = numel(this);
    md = string.empty(1, 0);
    for i = 1 : n
        md = [md, local_markdown(this(i), opt)];
    end

end%


function md = local_markdown(this, opt)
    %(
    md = string.empty(1, 0);

    stdErrors = sqrt(diag(this.Statistics.CovParameters));
    periodsFitted = this.Statistics.PeriodsFitted{1};
    numPeriodsFitted = numel(periodsFitted);
    if numPeriodsFitted==0
        periodsFitted = "";
    else
        range = periodsFitted(1) : periodsFitted(end);
        periodsFitted = dater.toDefaultString(periodsFitted);
        if numel(range) == numPeriodsFitted
            periodsFitted = sprintf("`%s`–`%s`", periodsFitted(1), periodsFitted(end));
        else
            periodsFitted = join(periodsFitted, " ");
        end
    end

    md = [md, sprintf(opt.Heading + " Equation for `%s`", this.LhsName), ""];
    md = [md, "* Type of equation: " + local_getType(this), ""];
    md = [md, "* Specification: `" + this.InputString + "`", ""];

    if ~this.IsIdentity
        md = [md, "* Number of periods fitted: " + string(numPeriodsFitted), ""];
        md = [md, "* Periods fitted: " + periodsFitted, ""];
        md = [md, "Parameter# | Estimate | Std. Error", ":-----------|---------:|------------:"];
        for i = 1 : numel(this.Parameters)
            md = [md, sprintf("%g | %g | %g", i, this.Parameters(i), stdErrors(i))];
        end
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
        residualModel = "plain";
    else
        residualModel = "ARMA";
    end

    type = type + sprintf(" and %s residuals", residualModel);
    %)
end%


