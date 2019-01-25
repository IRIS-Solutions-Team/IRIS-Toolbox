function outp = hdata2tseries(this, varargin)
% hdata2tseries  Convert hdataobj data to a tseries database
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

TIME_SERIES_CONSTRUCTOR = iris.get('DefaultTimeSeriesConstructor');
TIME_SERIES = TIME_SERIES_CONSTRUCTOR( );

opt = passvalopt('HData.hdata2tseries', varargin{:});

%--------------------------------------------------------------------------

outp = struct( );

ixLog = this.IxLog;
if ~opt.Delog
    ixLog(:) = false;
end

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
        name = this.Name{j};
        
        if ~isfield(this.Data,name)
            continue
        end
        sn = size(this.Data.(name));
        if sn(1)~=nXPer
            throw( exception.Base('General:Internal', 'error') );
        end
        if ixLog(j)
            this.Data.(name) = real(exp(this.Data.(name)));
        end
        
        % Create a new database entry.
        outp.(name) = fill( ...
            TIME_SERIES, ...
            this.Data.(name), ...
            xStart ...
        );
        s = size(outp.(name).data);
        if isempty(this.Contributions)            
            c = repmat(this.Label(j), [1, s(2:end)]);
        else
            c = utils.concomment(name, this.Contributions, ixLog(j));    
        end
        outp.(name).Comment = c;
        
        % Free memory.
        this.Data.(name) = [ ];
    end
end

if this.IncludeParam
    list = fieldnames(this.ParamDb);
    for i = 1 : numel(list)
    	outp.(list{i}) = this.ParamDb.(list{i});
    end
end

end%

