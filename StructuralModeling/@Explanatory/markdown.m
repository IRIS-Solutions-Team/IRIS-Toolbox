
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
        periodsFittedString = "";
    else
        range = periodsFitted(1) : periodsFitted(end);
        if numel(range) == numPeriodsFitted
            startString = dater.toDefaultString(range(1));
            endString = dater.toDefaultString(range(end));
            periodsFittedString = sprintf("`%s`–`%s`", startString, endString);
        else
            periodsFittedString = join(dater.toDefaultString(periodsFitted), " ");
        end
    end

    if ~this.IsIdentity
        heading = "Equation";
    else
        heading = "Identity";
    end
    md = [md, sprintf(opt.Heading + " " + heading + " for `%s`", this.LhsName), ""];
    md = [md, "* Type of equation: " + local_getType(this), ""];
    md = [md, "* Specification:", "", "```", this.InputString, "```", ""];

    if ~this.IsIdentity
        md = [md, "* Number of periods fitted: " + string(numPeriodsFitted), ""];
        md = [md, "* Periods fitted: " + periodsFittedString, ""];
        md = [md, "* Parameter estimates:", ""];
        md = [md, "Parameter# | Estimate | Std. Error", ":-----------|---------:|------------:"];
        for i = 1 : numel(this.Parameters)
            md = [md, sprintf("%g | %g | %g", i, this.Parameters(i), stdErrors(i))];
        end
        md = [md, ""];

        if this.HasResidualModel
            md = [md, "* Residual model:", ""];
            md = [md, "```"];
            md = [md, "AR=[" + join(string(this.ResidualModel.AR), ", ") + "]"];
            md = [md, "MA=[" + join(string(this.ResidualModel.MA), ", ") + "]"];
            md = [md, "```", ""];
        end
    end

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

    if this.HasResidualModel
        residuals = "ARMA residuals";
    else
        residuals = "plain residuals";
    end

    type = type + sprintf(" and %s", residuals);
    %)
end%


