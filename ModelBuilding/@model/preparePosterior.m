function [this, posterior] = preparePosterior(this, estimationSpecs, penalty, initialDatabank)
% preparePosterior  Parse estimation specs and prepare Posterior object
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

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
posValues = ell.PosName;
posStdCorr = ell.PosStdCorr;
indexValidNames = ~isnan(posValues) | ~isnan(posStdCorr);
assert( ...
    all(indexValidNames), ...
    exception.Base('Model:NotParameterInEstimationSpecs', 'warning'), ...
    fields{~indexValidNames} ...
);
numParameters = nnz(indexValidNames);
parameterNames = fields(indexValidNames);
posValues = posValues(indexValidNames);
posStdCorr = posStdCorr(indexValidNames);

% Store information for model.update
this.TaskSpecific = struct( );
this.TaskSpecific.Update.Values = this.Variant.Values;
this.TaskSpecific.Update.StdCorr = this.Variant.StdCorr;
this.TaskSpecific.Update.PosValues = posValues;
this.TaskSpecific.Update.PosStdCorr = posStdCorr;

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
parseEstimationSpecs( );
posterior.IndexPriors = ~cellfun('isempty', posterior.PriorDistributions);

return


    function parseEstimationSpecs( )
        for ii = 1 : numParameters
            ithName = parameterNames{ii};
            ithSpec = estimationSpecs.(ithName);
            if isnumeric(ithSpec)
                ithSpec = num2cell(ithSpec);
            end
            
            % __Starting Value__
            if isstruct(initialDatabank) ...
                    && isfield(initialDatabank, ithName) ...
                    && isnumeric(initialDatabank.(ithName)) ...
                    && isscalar(initialDatabank.(ithName))
                p0 = initialDatabank.(ithName);
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
                    % The 4th element is a prior distribution function handle.
                    ithPriorDistribution = ithSpec{4};
                %elseif isnumeric(ithSpec{4}) && isscalar(ithSpec{4}) && penalty>0
                %    % The 4th element is a penalty function.
                %    indexPenaltyFunction(ii) = true;
                %    ithPriorDistribution = ...
                %        penalty2Prior(ithSpec, p0, defaultInitial(ii), penalty);
                end
            end
            
            posterior.Initial(ii) = p0;
            posterior.LowerBounds(ii) = pl;
            posterior.UpperBounds(ii) = pu;
            posterior.PriorDistributions{ii} = ithPriorDistribution;
        end
    end
end


%{
function priorDistribution = penalty2Prior(spec, p0, defaultInitial, penalty)
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
    priorDistribution = distribution.Normal('MeanStd', pBar, sgm);
end
%}
