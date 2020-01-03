function d = emptydb(this, varargin)
% emptydb  Create model database with empty time series for each variable and shock
%
% ## Syntax ##
%
%     outputDatabank = emptydb(m)
%
%
% ## Input arguments ##
%
% * `m` [ model ] - Model for which the empty database will be created.
%
%
% ## Output arguments ##
%
% * `outputDatabank` [ struct ] - Databank with an empty time series for
% each variable and each shock, and a vector of currently assigned values
% for each parameter.
%
%
% ## Options ##
%
% * `Include=@all` [ char | cellstr | string | `@all` ] - Types of
% quantities that will be included in the output databank; `@all` means all
% variables, shocks and parameters will be included; see Description.
%
% * `Size=[0, 1]` [ numeric ] - Size of the empty time series; the size in
% first dimension must be zero.
%
%
% ## Description ##
%
% The output databank will, by default, include an empty time series for
% each measurement and transition variable, and measurement and transition
% shock, as well as a numeric array for each parameter. To create a
% databank with only some of these quantities, use the option `Include=`,
% and assign a cellstr or a string array combining the following:
%
% * `Variables` to include measurement and transition variables;
% * `MeasurementVariables` to include measurement variables;
% * `TransitionVariables` to include transition variables;
% * `Shocks` to include measurement and transition shocks;
% * `MeasurementShocks` to include measurement shocks;
% * `TransitionShocks` to include transition shocks;
% * `Parameters` to include parameters;
% * `Std` to include std deviations of shocks.
%
%
% ## Example ##
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

TIME_SERIES_CONSTRUCTOR = iris.get('DefaultTimeSeriesConstructor');
TYPE = @int8;

persistent parser
if isempty(parser)
    parser = extend.InputParser('model.emptydb');
    parser.addRequired('Model', @(x) isa(x, 'model'));
    parser.addParameter('Include', @all, @(x) isequal(x, @all) || ischar(x) || iscellstr(x) || isa(x, 'string'));
    parser.addParameter('Size', [0, 1], @(x) isnumeric(x) && numel(x)>=2 && x(1)==0 && all(x==round(x)) && all(x>=0));
end
parser.parse(this, varargin{:});
opt = parser.Options;

if ~isa(opt.Include, 'function_handle') && ~iscellstr(opt.Include)
    opt.Include = cellstr(opt.Include);
end

%--------------------------------------------------------------------------

if isequal(opt.Include, @all)
    typesToInclude = [TYPE(1), TYPE(2), TYPE(31), TYPE(32), TYPE(4)];
else
    typesToInclude = TYPE([ ]);
    if any(strcmpi(opt.Include, 'MeasurementVariables')) ...
       || any(strcmpi(opt.Include, 'Variables'))
        typesToInclude = [typesToInclude, TYPE(1)];
    end
    if any(strcmpi(opt.Include, 'TransitionVariables')) ...
       || any(strcmpi(opt.Include, 'Variables'))
        typesToInclude = [typesToInclude, TYPE(2)];
    end
    if any(strcmpi(opt.Include, 'MeasurementShocks')) ...
       || any(strcmpi(opt.Include, 'Shocks'))
        typesToInclude = [typesToInclude, TYPE(31)];
    end
    if any(strcmpi(opt.Include, 'TransitionShocks')) ...
       || any(strcmpi(opt.Include, 'Shocks'))
        typesToInclude = [typesToInclude, TYPE(32)];
    end
end

d = struct( );
if isempty(typesToInclude)
    return
end

inxOfParameters = this.Quantity.Type==TYPE(4);
emptyTimeSeries = TIME_SERIES_CONSTRUCTOR([ ], zeros(opt.Size));

% Add comment to time series for each variable
labelOrName = this.Quantity.LabelOrName;
for i = find(~inxOfParameters)
    if any(this.Quantity.Type(i)==typesToInclude)
        name = this.Quantity.Name{i};
        d.(name) = comment(emptyTimeSeries, labelOrName{i});
    end
end

% Add a value for each parameter
if ismember(TYPE(4), typesToInclude)
    d = addToDatabank({'Parameters', 'Std', 'NonzeroCorr'}, this, d);
end

end%

