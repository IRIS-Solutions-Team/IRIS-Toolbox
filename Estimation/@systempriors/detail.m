function detail(this)
% detail  Display details of system priors object.
%
% __Syntax__
%
%     detail(S)
%
%
% __Input Arguments__
%
% * `S` [ systempriors ] - System priors, 
% [`systempriors`](systempriors/Contents), object.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

numPriors = length(this.Eval);
numDigits = 1 + floor(log10(numPriors));
textual.looseLine( );
for i = 1 : numPriors
    if ~isempty(this.PriorFn{i})
        ithPrior = this.PriorFn{i};
        if isa(ithPrior, 'distribution.Abstract')
            priorFuncName = ithPrior.Name;
            priorMean = ithPrior.Mean;
            priorStd = ithPrior.Std;
        elseif isa(ithPrior, 'function_handle')
            priorFuncName = this.PriorFn{i}([ ], 'name');
            priorMean = this.PriorFn{i}([ ], 'mean');
            priorStd = this.PriorFn{i}([ ], 'std');
        end
        priorDescript = sprintf('%s Mean=%g Std=%g', ...
            priorFuncName, priorMean, priorStd);
    else
        priorDescript = 'Flat';
    end
    if all(isinf(this.Bounds(:, i)))
        boundsDescript = 'Unbounded';
    else
        boundsDescript = sprintf('Lower=%g Upper=%g', this.Bounds(:, i));
    end
    fprintf('\t#%*g\n', numDigits, i);
    fprintf('\tSystem Function: %s\n', this.UserString{i});
    fprintf('\tDistribution: %s\n', priorDescript);
    fprintf('\tBounds: %s\n', boundsDescript);
    textual.looseLine( );
end

end
