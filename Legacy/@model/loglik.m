% loglik  Evaluate minus the log-likelihood function in time or frequency domain.
%{
% ## Syntax ##
%
%     minusLogLik = loglik(model, inputDb, range, domain, ___)
%
%
% ## Syntax for Repeated Fast Likelihood Evaluations ##
%
% Input arguments marked with a `~` sign may be omitted.
%
%     % Step #1: Initialise.
%     loglik(M, Inp, range, ~J, ..., 'Persist', true);
%
%     % Step #2: Assign/change parameters.
%     M... = ...; % Change parameters.
%
%     % Step #3: Re-compute steady state and solution if necessary.
%     M = ...;
%     M = ...;
%
%     % Step #4: Evaluate likelihood.
%     L = loglik(M);
%
%     % Repeat steps #2, #3, #4 for different values of parameters.
%     % ...
%
%
% ## Input Arguments ##
%
% * `M` [ model ] - Solved model object.
%
% * `Inp` [ struct | cell ] - Input database from which observations for
% measurement variables will be taken.
%
% * `range` [ numeric | char ] - Date range on which the Kalman filter will
% be run.
%
%
% ## Output Arguments ##
%
% * `minusLogLik` [ numeric ] - Value of minus the log-likelihood function.
%
% * `V` [ numeric ] - Estimated variance scale factor if the `'relative='`
% options is true; otherwise `V` is 1.
%
% * `F` [ numeric ] - Sequence of forecast MSE matrices for
% measurement variables.
%
% * `PE` [ struct ] - Database with prediction errors for measurement
% variables; exp of prediction errors for measurement variables declared as
% log variables.
%
% * `Delta` [ struct ] - Databse with point estimates of the deterministic
% trend parameters specified in the `'outoflik='` option.
%
% * `PDelta` [ numeric ] - MSE matrix of the estimates of the `'outoflik='`
% parameters.
%
%
% ## Options ##
%
% * `'objDecomp='` [ `true` | *`false`* ] - Decompose the objective
% function into the contributions of individual time periods (in time
% domain) or individual frequencies (in frequency domain); the
% contributions are added as extra rows in the output argument `minusLogLik`.
%
% * `Persist=false` [ `true` | `false` ] -- Pre-process and store the overhead
% (data and options) for subsequent fast calls.
%
% See help on [`model/filter`](model/filter) for other options available.
%
%
% ## Description ##
%
% The number of output arguments you request when calling `loglik` affects
% computational efficiency. Running the function with only the first output
% argument, i.e. the value of the likelihood function (minus the log of it, 
% in fact), results in the fastest performance.
%
% The `loglik` function runs an identical Kalman filter as
% [`model/filter`](model/filter), the only difference is the types and
% order of output arguments returned.
%
%
% _Fast Evaluation of Likelihood_
%
% Every time you change the parameters, you need to update the steady state
% and solution of the model if necessary by yourself, before calling
% `loglik`. Follow these rules:
%
% * If you only change std deviations and no other parameters, you don't
% have to re-calculate steady state or solution.
%
% * If the model is linear, you only need to call [`solve`](model/solve).
%
% * The only exception to rules #2 and #3 is when the model has [`dynamic
% links`](irislang/links) with references to some steady state values. In
% that case, you must also run [`sstate`](model/sstate) after
% [`solve`](model/solve) in linear models to update the steady state.
%
% * If the model is non-linear, and you only change parameters that affect
% transitory dynamics and not the steady state, you only need to call
% [`solve`](model/solve).
%
% * If the model is non-linear, and you change parameters that affect both
% transitory dynamics and steady state, you must run first
% [`sstate`](model/sstate) and then [`solve`](model/solve).
%
%
% ## Example ##
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 IRIS Solutions Team

% These variables are cleared at the end of the file unless the user
% specifies `persist=true`.

function minusLogLik = loglik(this, inputData, range, varargin)

    persistent DATA RANGE DOMAIN EXTENDED_RANGE OPT

    % If loglik(m) is called without any further input arguments, the last ones
    % passed in will be used if `'persistent='` was set to `true`.
    if nargin==1
        if isempty(OPT)
            exception.error([
                "Model"
                "The loglik() function has not been initialized for repeated evaluation."
            ]);
        end
    else
        RANGE = reshape(double(range), 1, [ ]);
        EXTENDED_RANGE = [dater.plus(RANGE(1), -1), RANGE];


        DOMAIN = "time";
        if ~isempty(varargin)
            if strcmpi(varargin{1}, ["t", "time"])
                DOMAIN = "time";
                varargin(1) = [];
            elseif strcmpi(varargin{1}, ["f", "freq", "frequency"])
                DOMAIN = "frequency";
                varargin(1) = [];
            end
        end


        if DOMAIN=="time"
            OPT = prepareKalmanOptions2(this, RANGE, varargin{:});
            DATA = datarequest('tyg*', this, inputData, RANGE, ':');
        else
            OPT = prepareFreckleOptions2(this, RANGE, varargin{:});
            DATA = datarequest('fyg*', this, inputData, RANGE, ':');
        end
    end


    %=========================================================================
    argin = struct( ...
        'InputData', DATA, ...
        'OutputData', [ ], ...
        'InternalAssignFunc', [ ], ...
        'Options', OPT ...
    );

    if DOMAIN=="time"
        minusLogLik = implementKalmanFilter(this, argin);
    else
        minusLogLik = implementFreckle(this. argin);
    end
    %=========================================================================


    if ~OPT.Persist
        DATA   = [];
        DOMAIN = [];
        RANGE = [];
        EXTENDED_RANGE  = [];
        opt = [];
    end

end%

