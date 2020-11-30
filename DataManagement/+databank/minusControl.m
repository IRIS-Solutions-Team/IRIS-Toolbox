% minusControl  Create simulation-minus-control database
%{
% ## Syntax ##
%
%    [inputDb, controlDb] = databank.minusControl(model, inputDb)
%    [inputDb, controlDb] = databank.minusControl(model, inputDb, controlDb)
%
%
% ## Input Arguments ##
%
% * `model` [ model ] - Model object on which the databases `inputDb` and `controlDb` are
% based.
%
% * `inputDb` [ struct ] - Simulation database.
%
% * `controlDb` [ struct ] - Control database; if the input argument `controlDb` is
% omitted the steady-state database of the model `M` is used for the
% control database.
%
%
% ## Output Arguments ##
%
% * `outputData` [ struct ] - Simulation-minus-control database, in which all
% log variables are `d.x/c.x`, and all other variables are `d.x-c.x`.
%
% * `controlDb` [ struct ] - Control database that has been
% subtracted from the `inputDb` database to create
% `outputData`.
%
%
% ## Description ##
%
%
% ## Example ##
%
% Run a shock simulation in full levels using a steady-state (or
% balanced-growth-path) database as input, and then compute the deviations
% from the steady state:
%
%```
%     d = steadydb(m, 1:40);
%     % Set up a shock or shocks here
%     s = simulate(m, d, 1:40, "prependInput", true);
%     s = databank.minusControl(m, s, d);
%```
%
% or simply
%
%```
%     s = databank.minusControl(m, s);
%```
%
% The above block of code is equivalent to this one:
%
%```
%     d = zerodb(m, 1:40);
%     % Set up a shock or shocks here
%     s = simulate(m, d, 1:40, 'deviation', true, "prependInput", true);
%```
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%#ok<*VUNUS>
%#ok<*CTCH>

function outputDb = minusControl(model, inputDb, controlDb, opt)

arguments
    model Model
    inputDb {validate.databank}
    controlDb {validate.databank} = struct([])

    opt.Range {validate.range} = Inf
end

if isempty(controlDb) || isempty(fieldnames(controlDb))
    dbRange = databank.range(inputDb, "sourceNames", string(fieldnames(inputDb)));
    if iscell(dbRange)
        exception.error([
            "Databank:MixedFrequency"
            "Input time series must be all of the same date frequency."
        ]);
    end
    controlDb = steadydb(model, dbRange);
end

quantity = getp(model, "Quantity");
inx = getIndexByType(quantity, 1, 2, 31, 32);
outputDb = struct();
for pos = reshape(find(inx), 1, [])
    n = quantity.Name{pos};
    if isfield(inputDb, n) && isfield(controlDb, n)
        if quantity.InxLog(pos)
            func = @rdivide;
        else
            func = @minus;
        end
        try
            outputSeries = bsxfun( ...
                func, ...
                real(inputDb.(n)), ...
                real(controlDb.(n)) ...
            );
            outputSeries = comment(outputSeries, inputDb.(n));
            outputDb.(n) = outputSeries;
        end
    end
end

end%

