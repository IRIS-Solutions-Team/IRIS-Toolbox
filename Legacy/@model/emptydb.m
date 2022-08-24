function d = emptydb(this, varargin)

persistent ip
if isempty(ip)
    ip = extend.InputParser('model.emptydb');
    ip.addRequired('Model', @(x) isa(x, 'model'));
    ip.addParameter('Include', @all, @(x) isequal(x, @all) || ischar(x) || iscellstr(x) || isa(x, 'string'));
    ip.addParameter('Size', @auto, @(x) isequal(x, @auto) || (isnumeric(x) && numel(x)>=2 && x(1)==0 && all(x==round(x)) && all(x>=0)));
end
ip.parse(this, varargin{:});
opt = ip.Options;

if ~isa(opt.Include, 'function_handle') && ~iscellstr(opt.Include)
    opt.Include = cellstr(opt.Include);
end

%--------------------------------------------------------------------------

if isequal(opt.Include, @all)
    typesToInclude = [1, 2, 31, 32, 4];
else
    typesToInclude = [];
    if any(strcmpi(opt.Include, 'MeasurementVariables')) ...
       || any(strcmpi(opt.Include, 'Variables'))
        typesToInclude = [typesToInclude, 1];
    end
    if any(strcmpi(opt.Include, 'TransitionVariables')) ...
       || any(strcmpi(opt.Include, 'Variables'))
        typesToInclude = [typesToInclude, 2];
    end
    if any(strcmpi(opt.Include, 'MeasurementShocks')) ...
       || any(strcmpi(opt.Include, 'Shocks'))
        typesToInclude = [typesToInclude, 31];
    end
    if any(strcmpi(opt.Include, 'TransitionShocks')) ...
       || any(strcmpi(opt.Include, 'Shocks'))
        typesToInclude = [typesToInclude, 32];
    end
end

d = struct( );
if isempty(typesToInclude)
    return
end

inxParameters = this.Quantity.Type==4;
if isequal(opt.Size, @auto)
    opt.Size = [0, countVariants(this)];
end
emptyTimeSeries = Series([], zeros(opt.Size));


% Add comment to time series for each variable
labelsOrNames = getLabelsOrNames(this.Quantity);
for i = find(~inxParameters)
    if any(this.Quantity.Type(i)==typesToInclude)
        name = this.Quantity.Name{i};
        d.(name) = comment(emptyTimeSeries, labelsOrNames(i));
    end
end

% Add a value for each parameter
if ismember(4, typesToInclude)
    d = addToDatabank({'Parameters', 'Std', 'NonzeroCorr'}, this, d);
end

end%

