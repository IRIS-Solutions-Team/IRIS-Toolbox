function X = dAdI(This,X,ind)
% pderiv  [Not a public function]
%
% First derivative of the activation function with respect to the input.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.


assert(isintscalar(ind)) ;

if intersect(ind,This.ActivationIndexLocal)
    switch This.ActivationFn
        case 'bias'
            X = 0 ;
            
        case 'linear'
            X = This.ActivationParams(ind) ;
            
        otherwise
            utils.error('nnet','Symbolic differentiation not available for activation function of type %s\n',This.OutputFn) ;
    end
else
    X = 0 ;
end


