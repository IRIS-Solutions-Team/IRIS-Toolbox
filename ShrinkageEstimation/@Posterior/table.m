function summary = table(this)

posterStd = sqrt(diag(this.ProposalCov));
posterStd(~this.IndexValidDiff) = NaN;
numParameters = this.NumParameters;
priorName = repmat("Flat", 1, numParameters);
priorMean = nan(1, numParameters);
priorMode = nan(1, numParameters);
priorStd = nan(1, numParameters);
for i = find(this.IndexPriors)
    try
        priorName(i) = string(this.PriorDistributions{i}.Name);
        priorMean(i) = this.PriorDistributions{i}.Mean;
        priorMode(i) = this.PriorDistributions{i}.Mode;
        priorStd(i) =  this.PriorDistributions{i}.Std;
    end
end


%
% Prepare temporary variable with the breakdown of system prior information
%

breakdown = [];
for i = 1 : numel(this.LineInfoFromSystemPriorsBreakdown)
    breakdown = [breakdown; this.LineInfoFromSystemPriorsBreakdown{i}];
end


variables = {
    this.Optimum(:), 'PosterMode', 'Posterior mode'
    posterStd(:), 'PosterStd', 'Posterior std deviation'
    priorName(:), 'IndiePriorFunc', 'Individual prior distribution function'
    [priorMean(:), priorMode(:), priorStd(:)], 'IndiePriorMeanModeStd', 'Individual prior mean, mode, std'
    [this.LowerBounds(:), this.UpperBounds(:)], 'Bounds', 'Lower and upper bounds'
    this.LineInfo(:), 'Info', 'Total Fisher information'
    [this.LineInfoFromData(:), this.LineInfoFromIndividualPrior(:), this.LineInfoFromSystemPriors(:)], 'InfoBreakdown', 'Breakdown of Fisher information'
    breakdown, 'SystemPriorInfoBreakdown', 'Breakdown of Fisher information from system priors'
    this.Initial(:), 'Start', 'Starting Value'
};

summary = table( ...
    variables{:, 1}, ...
    'RowNames', this.ParameterNames, ...
    'VariableNames', reshape(variables(:, 2), 1, []) ...
);

summary.Properties.VariableDescriptions = reshape(variables(:, 3), 1, []);

end%

