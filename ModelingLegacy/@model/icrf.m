function [s, range, select] = icrf(this, time, varargin)
% icrf  Initial-condition response functions, first-order solution only
%
% __Syntax__
%
%     S = icrf(M, NPer, ...)
%     S = icrf(M, Range, ...)
%
%
% __Input Arguments__
%
% * `M` [ model ] - Model object for which the initial condition responses
% will be simulated.
%
% * `Range` [ numeric | char ] - Date range with the first date being the
% shock date.
%
% * `NPer` [ numeric ] - Number of periods.
%
%
% __Output Arguments__
%
% * `S` [ struct ] - Databank with initial condition response series.
%
%
% __Options__
%
% * `'Delog='` [ *`true`* | `false` ] - Delogarithmise the responses for
% variables declared as `!log_variables`.
%
% * `'Size='` [ numeric | *`1`* for linear models | *`log(1.01)`* for non-linear
% models ] - Size of the deviation in initial conditions.
%
%
% __Description__
%
% Function `icrf` returns the responses of all model variables to a
% deviation (of a given size) in one initial condition. All other
% initial conditions remain undisturbed and all shocks remain zero in the
% simulation.
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

% Parse options.
opt = passvalopt('model.icrf', varargin{:});

% TODO: Introduce `'select='` option.

%--------------------------------------------------------------------------

[~, ~, nb] = sizeOfSolution(this.Vector);

% Set the size of the initial conditions.
if isempty(opt.size)
    % Default.
    if this.IsLinear
        sizeOfDeviation = ones(1, nb);
    else
        sizeOfDeviation = ones(1, nb)*log(1.01);
    end
else
    % User supplied.
    sizeOfDeviation = ones(1, nb)*opt.size;
end

select = get(this, 'initCond');
select = regexprep(select, 'log\((.*?)\)', '$1', 'once');

func = @(T, R, K, Z, H, D, U, Omg, ~, numOfPeriods) ...
    timedom.icrf(T, [ ], [ ], Z, [ ], [ ], U, [ ], numOfPeriods, sizeOfDeviation);

[s, range] = responseFunction(this, time, func, select, opt);

end
