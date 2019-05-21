function [dmc, controlData] = dbminuscontrol(varargin)
% dbminuscontrol  Create simulation-minus-control database
%
%
% __Syntax__
%
%    [inputData, controlData] = dbminuscontrol(model, inputData)
%    [inputData, controlData] = dbminuscontrol(model, inputData, controlData)
%
%
% _Input Arguments_
%
% * `model` [ model ] - Model object on which the databases `inputData` and `controlData` are
% based.
%
% * `inputData` [ struct ] - Simulation database.
%
% * `controlData` [ struct ] - Control database; if the input argument `controlData` is
% omitted the steady-state database of the model `M` is used for the
% control database.
%
%
% __Output Arguments__
%
% * `outputData` [ struct ] - Simulation-minus-control database, in which all
% log variables are `d.x/c.x`, and all other variables are `d.x-c.x`.
%
% * `controlData` [ struct ] - Control database that has been
% subtracted from the `inputData` database to create
% `outputData`.
%
%
% __Options__
%
% * `Fresh=false` [ `true` | `false` ] - If `true`, the output database will
% only contain entries corresponding to model variables in `M`; if `false`
% all other entries found in the input database will be also kept in the
% output database.
%
%
% __Description__
%
%
% __Example__
%
% We run a shock simulation in full levels using a steady-state (or
% balanced-growth-path) database as input, and then compute the deviations
% from the steady state.
%
%     d = sstatedb(m, 1:40);
%     ... % Set up a shock or shocks here.
%     s = simulate(m, d, 1:40);
%     s = dboverlay(d, s);
%     s = dbminuscontrol(m, s, d);
%
% The above block of code is equivalent to this one:
%
%     d = zerodb(m, 1:40);
%     ... % Set up a shock or shocks here.
%     s = simulate(m, d, 1:40, 'deviation=', true);
%     s = dboverlay(d, s);
%

% -The IRIS Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%#ok<*VUNUS>
%#ok<*CTCH>

[this, inputData, controlData, varargin] = irisinp.parser.parse('dbase.dbminuscontrol', varargin{:});
opt = passvalopt('dbase.dbminuscontrol', varargin{:});

%--------------------------------------------------------------------------

list = [get(this, 'YList'), get(this, 'XList'), get(this, 'EList')];
isLog = get(this, 'IsLog');

if isempty(controlData)
    range = dbrange(inputData, list, ...
        'StartDate=', 'MaxRange', 'EndDate=', 'MaxRange');
    controlData = sstatedb(this, range);
end

dmc = inputData;
ixKeep = true(size(list));
for i = 1 : length(list)
    name = list{i};
    if isfield(inputData, name) && isfield(controlData, name)
        if isLog.(name)
            func = @rdivide;
        else
            func = @minus;
        end
        try
            dmc.(name) = bsxfun( func, ...
                                 real(inputData.(name)), ...
                                 real(controlData.(name)) );
            dmc.(name) = comment(dmc.(name), inputData.(name));
        catch %#ok<CTCH>
            ixKeep(i) = false;
        end
    else
        ixKeep(i) = false;
    end
end

if opt.fresh && any(~ixKeep)
    dmc = rmfield(dmc, list(~ixKeep));
end

end%

