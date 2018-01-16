function [Obj,Pred,This] = objfunc(X,This,InData,OutData,Range,options)
% OBJFUNC  [Not a public function] Objective function value.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.
    
%**************************************************************************

[This,Flag] = myupdatemodel(This,X,options) ;
if ~Flag
    utils.error('nnet:objfunc',...
        'Parameter update failure.') ;
end

Pred = eval(This,InData,Range) ; %#ok<*GTARG>

Obj = options.Norm(OutData-Pred) ;

end
