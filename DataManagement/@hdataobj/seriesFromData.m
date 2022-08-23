% hdata2tseries  Convert hdataobj data to time series databank
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function outp = seriesFromData(this, type)

TIME_SERIES = Series();

outp = struct( );

inxLog = this.IxLog;

for i = 1 : numel(this.Id)
    if isempty(this.Id{i})
        continue
    end

    realId = real(this.Id{i});
    imagId = imag(this.Id{i});
    maxLag = -min(imagId);

    if this.IncludeLag && maxLag>0
        xRange = this.Range(1)-maxLag : this.Range(end);
    else
        xRange = this.Range(1) : this.Range(end);
    end
    xStart = xRange(1);
    nXPer = length(xRange);

    for j = sort(realId(imagId==0))
        name = string(this.Name{j});

        if ~isfield(this.Data, name)
            continue
        end
        sn = size(this.Data.(name));
        if sn(1)~=nXPer
            raise( exception.Base('General:Internal', 'error') );
        end

        data = this.Data.(name);

        if inxLog(j)
            if type=="median"
                data = real(exp(data));
            else
                name = model.Quantity.LOG_PREFIX + name;
            end
        end

        outp.(name) = fill(TIME_SERIES, data, xStart);

        s = size(outp.(name).data);
        if isempty(this.Contributions)
            c = repmat(this.Label(j), [1, s(2:end)]);
        else
            c = string(name) + this.CONTRIBUTION_SIGN + string(this.Contributions);
        end
        outp.(name).Comment = c;
    end
end

if this.IncludeParam
    list = fieldnames(this.ParamDb);
    for i = 1 : numel(list)
        outp.(list{i}) = this.ParamDb.(list{i});
    end
end

end%

