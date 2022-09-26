% preparePosteriorAndUpdate  Parse estimation specs, prepare Posterior object and transient model.Update
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function [this, posterior] = preparePosteriorAndUpdate(this, estimSpecs, opt)

% Remove empty entries from estimation specs
fields = fieldnames(estimSpecs).';
numFields = numel(fields);
indexToRemove = false(1, numFields);
for i = 1 : numFields
    if isempty(estimSpecs.(fields{i}))
        indexToRemove(i) = true;
    end
end
estimSpecs = rmfield(estimSpecs, fields(indexToRemove));
fields(indexToRemove) = [ ];

% Parameters to estimate and their positions; remove names that are not
% valid parameter names, and throw a warning for them
ell = lookup(this.Quantity, fields);
posValues = ell.PosName;
posStdCorr = ell.PosStdCorr;
inxValidNames = ~isnan(posValues) | ~isnan(posStdCorr);
if ~all(inxValidNames)
    throw( exception.Base('Model:NotParameterInEstimationSpecs', 'warning'), ...
           fields{~inxValidNames} );
end
numParameters = nnz(inxValidNames);
parameterNames = fields(inxValidNames);
posValues = posValues(inxValidNames);
posStdCorr = posStdCorr(inxValidNames);

% Populate transient model.Update
this.Update = this.EMPTY_UPDATE;
this.Update.Values = this.Variant.Values;
this.Update.StdCorr = this.Variant.StdCorr;
this.Update.PosOfValues = posValues;
this.Update.PosOfStdCorr = posStdCorr;

if islogical(opt.Steady)
    opt.Steady ={"run", opt.Steady};
end
this.Update.Steady = prepareSteady(this, "silent", true, opt.Steady{:});

if islogical(opt.CheckSteady)
    opt.CheckSteady = {"run", opt.CheckSteady};
end
this.Update.CheckSteady = prepareCheckSteady(this, "silent", true, opt.CheckSteady{:});

if islogical(opt.Solve)
    opt.Solve = {"run", opt.Solve};
end
this.Update.Solve = prepareSolve(this, "silent", true, opt.Solve{:});

this.Update.NoSolution = opt.NoSolution;

% __Starting Values__
% Prepare the value currently assigned in the model object; this is used
% when the starting value in the estimation specs is NaN or @auto
defaultInitial = nan(1, numParameters);
for i = 1 : numParameters
    if ~isnan(posValues(i))
        defaultInitial(i) = this.Variant.Values(:, posValues(i), :);
    else
        defaultInitial(i) = this.Variant.StdCorr(:, posStdCorr(i), :);
    end
end

posterior = Posterior(numParameters);
posterior.ParameterNames = parameterNames;
here_parseEstimationSpecs( );
posterior.IndexPriors = ~cellfun('isempty', posterior.PriorDistributions);

return


    function here_parseEstimationSpecs()
        hasStartIterations = isfield(opt, 'StartIterations') && isstruct(opt.StartIterations);

        invalidPriorSpecs = string.empty(1, 0);

        for ii = 1 : numParameters
            name__ = parameterNames{ii};
            spec__ = estimSpecs.(name__);
            if isnumeric(spec__)
                spec__ = num2cell(spec__);
            end

            % Start iterations from
            if hasStartIterations ...
                    && isfield(opt.StartIterations, name__) ...
                    && isnumeric(opt.StartIterations.(name__)) ...
                    && isscalar(opt.StartIterations.(name__))
                init__ = opt.StartIterations.(name__);
            elseif ~isempty(spec__) ...
                    && isnumeric(spec__{1}) ...
                    && isscalar(spec__{1})
                init__ = spec__{1};
            else
                init__ = NaN;
            end

            % If the starting value is NaN at this point, use the currently assigned
            % value from the model object, defaultInitial
            if isequaln(init__, NaN)
                init__ = defaultInitial(ii);
            end

            % __Lower and upper bounds__
            if length(spec__)>1 && isnumeric(spec__{2}) && isscalar(spec__{2})
                lower__ = spec__{2};
            else
                lower__ = -Inf;
            end
            if length(spec__)>2  && isnumeric(spec__{3}) && isscalar(spec__{3})
                upper__ = spec__{3};
            else
                upper__ = Inf;
            end

            % __Prior Distribution Function__
            priorDistribution__ = [ ];
            if length(spec__)>3 && ~isempty(spec__{4})
                if isa(spec__{4}, 'distribution.Distribution')
                    priorDistribution__ = spec__{4};
                elseif isa(spec__{4},'function_handle')
                    % The 4th element is a prior distribution function handle
                    priorDistribution__ = spec__{4};
                % elseif isnumeric(spec__{4}) && isscalar(spec__{4}) && opt.Penalty>0
                    % The 4th element is a penalty function
                    % priorDistribution__ = ...
                    %     penaltyToDistribution(spec__, init__, defaultInitial(ii), opt.Penalty);
                else
                    invalidPriorSpecs(end+1) = name__;
                end
            end

            posterior.Initial(ii) = init__;
            posterior.LowerBounds(ii) = lower__;
            posterior.UpperBounds(ii) = upper__;
            posterior.PriorDistributions{ii} = priorDistribution__;
        end

        if ~isempty(invalidPriorSpecs)
            exception.error([
                "Model"
                "Invalid prior distribution specification for this parameter: %s"
            ], invalidPriorSpecs);
        end
    end%
end%


%{
function priorDistribution = penaltyToDistribution(spec, init, defaultInitial, penalty)
    % The 4th entry is a penalty function, compute the
    % total weight including the Penalty option.
    totalWeight = spec{4}(1)*penalty;
    if isscalar(spec{4})
        % Only the weight specified. The centre of penalty
        % function is then set identical to the starting
        % value.
        pBar = init;
    else
        % Both the weight and the centre specified.
        pBar = spec{4}(2);
    end
    if isnan(pBar)
        pBar = defaultInitial;
    end
    % Convert penalty function to a normal prior:
    %
    % w*(p - pbar)^2==1/2*((p - pbar)/sgm)^2 => sgm =
    % 1/sqrt(2*w).
    %
    sgm = 1/sqrt(2*totalWeight);
    priorDistribution = distribution.Normal.fromMeanStd(pBar, sgm);
end%
%}
