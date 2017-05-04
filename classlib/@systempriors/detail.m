function detail(this)
% detail  Display details of system priors object.
%
% Syntax
% =======
%
%     detail(s)
%
%
% Input arguments
% ================
%
% * `s` [ systempriors ] - System priors, 
% [`systempriors`](systempriors/Contents), object.
%
%
% Description
% ============
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

nPrior = length(this.Eval);
nDigit = 1 + floor(log10(nPrior));
textfun.loosespace( );
for i = 1 : nPrior
    if ~isempty(this.PriorFn{i})
        priorFuncName = this.PriorFn{i}([ ], 'name');
        priorMean = this.PriorFn{i}([ ], 'mean');
        priorStd = this.PriorFn{i}([ ], 'std');
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
    fprintf('\t#%*g\n', nDigit, i);
    fprintf('\tSystem Function: %s\n', this.UserString{i});
    fprintf('\tDistribution: %s\n', priorDescript);
    fprintf('\tBounds: %s\n', boundsDescript);
    textfun.loosespace( );
end

end
