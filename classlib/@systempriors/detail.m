function detail(This)
% detail  Display details of system priors object.
%
% Syntax
% =======
%
%     detail(S)
%
% Input arguments
% ================
%
% * `S` [ systempriors ] - System priors,
% [`systempriors`](systempriors/Contents) object.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

nPrior = length(This.Eval);
nDigit = 1 + floor(log10(nPrior));
textfun.loosespace( );
for i = 1 : nPrior
    if ~isempty(This.PriorFn{i})
        priorFuncName = This.PriorFn{i}([ ],'name');
        priorMean = This.PriorFn{i}([ ],'mean');
        priorStd = This.PriorFn{i}([ ],'std');
        priorDescript = sprintf('Distribution: %s mean=%g std=%g', ...
            priorFuncName,priorMean,priorStd);
    else
        priorDescript = '[]';
    end
    fprintf('\t#%*g  %s\n',nDigit,i,This.UserString{i});
    fprintf('\t\t%s\n',priorDescript);
    fprintf('\t\tBounds: lower=%g upper=%g\n', ...
        This.LowerBnd(i),This.UpperBnd(i));
    textfun.loosespace( );
end

end
