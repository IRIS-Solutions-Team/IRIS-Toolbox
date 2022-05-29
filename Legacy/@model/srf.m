function [s, range, select, opt] = srf(this, time, varargin)
% srf  First-order shock response functions
%
% ## Syntax ##
%
%     S = srf(M, NPer, ...)
%     S = srf(M, Range, ...)
%
%
% ## Input Arguments ##
%
% * `M` [ model ] - Model object whose shock responses will be simulated.
%
% * `Range` [ numeric | char ] - Simulation date range with the first date
% being the shock date.
%
% * `NPer` [ numeric ] - Number of simulation periods.
%
%
% ## Output Arguments ##
%
% * `S` [ struct ] - Databank with shock response time series.
%
%
% ## Options ##
%
% * `Delog=true` [ `true` | `false` ] - Delogarithmize shock responses for
% log variables.
%
% * `Select=@all` [ cellstr | `@all` ] - Run the shock response function
% for a selection of shocks only; `@all` means all shocks are simulated.
%
% * `Size=@auto` [ `@auto` | numeric ] - Size of the shocks that will be
% simulated; `@auto` means that each shock will be set to its std dev
% currently assigned in the model object `M`.
%
%
% ## Description ##
% 
%
% ## Example ##
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('model.srf');
    parser.addRequired('SolvedModel', @validate.solvedModel);
    parser.addRequired('Time', @(x) isnumeric(x) || isa(x, 'DateWrapper')); 
    parser.addParameter('Delog', true, @validate.logicalScalar);
    parser.addParameter('Select', @all, @(x) ~isempty(x) && (isequal(x, @all) || validate.list(x)));
    parser.addParameter('Size', @auto, @(x) isequal(x, @auto) || validate.numericScalar(x));
end
parse(parser, this, time, varargin{:});
opt = parser.Options;

if ~isequal(opt.Select, @all)
    if ischar(opt.Select)
        opt.Select = regexp(opt.Select, '\w+', 'match');
    else
        opt.Select = cellstr(opt.Select);
    end
end

%--------------------------------------------------------------------------

inxOfE = getIndexByType(this.Quantity, 31, 32);
numOfE = sum(inxOfE);
nv = length(this);
listOfE = this.Quantity.Name(inxOfE);

% Select shocks
if isequal(opt.Select, @all)
    posOfSelected = 1 : numOfE;
else
    [inxOfValidNames, posOfSelected] = ismember(opt.Select, listOfE);
    %{
    numOfSelected = length(opt.Select);
    posOfSelected = nan(1, numOfSelected);
    for i = 1 : length(opt.Select)
        x = find( strcmp(opt.Select{i}, listOfE) );
        if length(x)==1
            posOfSelected(i) = x;
        end
    end
    %}
    if any(~inxOfValidNames)
        throw( exception.Base('Model:InvalidName', 'error'), ...
               'shock', opt.Select{~inxOfValidNames} );
    end
end
select = listOfE(posOfSelected);
numOfSelected = length(select);

% Set size of shocks
if strcmpi(opt.Size, 'std') ...
        || isequal(opt.Size, @auto) ...
        || isequal(opt.Size, @std)
    sizeOfShocks = this.Variant.StdCorr(:, posOfSelected, :);
else
    sizeOfShocks = opt.Size*ones(1, numOfSelected, nv);
end

func = @( T, R, K, Z, H, D, U, Omg, variantRequested, numOfPeriods) ...
          timedom.srf(T, R(:, posOfSelected), [ ], Z, H(:, posOfSelected), [ ], U, [ ], ...
          numOfPeriods, sizeOfShocks(1, :, variantRequested));

[s, range, select] = responseFunction(this, time, func, select, opt);
for i = 1 : length(select)
    s.(select{i}).data(1, i, :) = sizeOfShocks(1, i, :);
    s.(select{i}) = trim(s.(select{i}));
end

s = addToDatabank({'Parameters', 'Std', 'NonzeroCorr'}, this, s);

end%

