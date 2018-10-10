function [this, posterior] = preparePosteriorAndUpdate(this, estimationSpecs, opt)
% preparePosteriorAndUpdate  Parse estimation specs, prepare Posterior object and transient model.Update
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

%--------------------------------------------------------------------------

% Remove empty entries from estimation specs
fields = fieldnames(estimationSpecs).';
numFields = numel(fields);
indexToRemove = false(1, numFields);
for i = 1 : numFields
    if isempty(estimationSpecs.(fields{i}))
        indexToRemove(i) = true;
    end
end
estimationSpecs = rmfield(estimationSpecs, fields(indexToRemove));
fields(indexToRemove) = [ ];

% Parameters to estimate and their positions; remove names that are not
% valid parameter names, and throw a warning for them
ell = lookup(this.Quantity, fields);
posOfValues = ell.PosName;
posOfStdCorr = ell.PosStdCorr;
indexOfValidNames = ~isnan(posOfValues) | ~isnan(posOfStdCorr);
if ~all(indexOfValidNames)
    throw( exception.Base('Model:NotParameterInEstimationSpecs', 'warning'), ...
           fields{~indexOfValidNames} );
end
numOfParameters = nnz(indexOfValidNames);
parameterNames = fields(indexOfValidNames);
posOfValues = posOfValues(indexOfValidNames);
posOfStdCorr = posOfStdCorr(indexOfValidNames);

% Populate transient model.Update
this.Update = this.EMPTY_UPDATE;
this.Update.Values = this.Variant.Values;
this.Update.StdCorr = this.Variant.StdCorr;
this.Update.PosOfValues = posOfValues;
this.Update.PosOfStdCorr = posOfStdCorr;
this.Update.Steady = prepareSteady(this, 'silent', opt.Steady);
this.Update.CheckSteady = prepareChkSteady(this, 'silent', opt.ChkSstate);
this.Update.Solve = prepareSolve(this, 'silent', opt.Solve);
this.Update.NoSolution = opt.NoSolution;

% __Starting Values__
% Prepare the value currently assigned in the model object; this is used
% when the starting value in the estimation specs is NaN or @auto
defaultInitial = nan(1, numOfParameters);
for i = 1 : numOfParameters
    if ~isnan(posOfValues(i))
        defaultInitial(i) = this.Variant.Values(:, posOfValues(i), :);
    else
        defaultInitial(i) = this.Variant.StdCorr(:, posOfStdCorr(i), :);
    end
end

posterior = Posterior(numOfParameters);
posterior.ParameterNames = parameterNames;
parseEstimationSpecs( );
posterior.IndexPriors = ~cellfun('isempty', posterior.PriorDistributions);

return


    function parseEstimationSpecs( )
        fieldInitVal = isfield(opt, 'InitVal');
        for ii = 1 : numOfParameters
            ithName = parameterNames{ii};
            ithSpec = estimationSpecs.(ithName);
            if isnumeric(ithSpec)
                ithSpec = num2cell(ithSpec);
            end
            
            % __Starting Value__
            if fieldInitVal ...
                    && isstruct(opt.InitVal) ...
                    && isfield(opt.InitVal, ithName) ...
                    && isnumeric(opt.InitVal.(ithName)) ...
                    && isscalar(opt.InitVal.(ithName))
                p0 = opt.InitVal.(ithName);
            elseif ~isempty(ithSpec) ...
                    && isnumeric(ithSpec{1}) ...
                    && isscalar(ithSpec{1})
                p0 = ithSpec{1};
            else
                p0 = NaN;
            end
            % If the starting value is NaN at this point, use the currently assigned
            % value from the model object, defaultInitial
            if isequaln(p0, NaN)
                p0 = defaultInitial(ii);
            end
            
            % __Lower and Upper Bounds__
            if length(ithSpec)>1 && isnumeric(ithSpec{2}) && isscalar(ithSpec{2})
                pl = ithSpec{2};
            else
                pl = -Inf;
            end
            if length(ithSpec)>2  && isnumeric(ithSpec{3}) && isscalar(ithSpec{3})
                pu = ithSpec{3};
            else
                pu = Inf;
            end
            
            % __Prior Distribution Function__
            ithPriorDistribution = [ ];
            if length(ithSpec)>3 && ~isempty(ithSpec{4})
                if isa(ithSpec{4}, 'distribution.Abstract')
                    ithPriorDistribution = ithSpec{4};
                elseif isa(ithSpec{4},'function_handle')
                    % The 4th element is a prior distribution function handle
                    ithPriorDistribution = ithSpec{4};
                elseif isnumeric(ithSpec{4}) && isscalar(ithSpec{4}) && opt.Penalty>0
                    % The 4th element is a penalty function
                    ithPriorDistribution = ...
                        penaltyToDistribution(ithSpec, p0, defaultInitial(ii), opt.Penalty);
                end
            end
            
            posterior.Initial(ii) = p0;
            posterior.LowerBounds(ii) = pl;
            posterior.UpperBounds(ii) = pu;
            posterior.PriorDistributions{ii} = ithPriorDistribution;
        end
    end%
end%


function priorDistribution = penaltyToDistribution(spec, p0, defaultInitial, penalty)
    % The 4th entry is a penalty function, compute the
    % total weight including the `'penalty='` option.
    totalWeight = spec{4}(1)*penalty;
    if isscalar(spec{4})
        % Only the weight specified. The centre of penalty
        % function is then set identical to the starting
        % value.
        pBar = p0;
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
