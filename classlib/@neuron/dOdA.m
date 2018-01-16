function [out] = dOdA(This,in)
% pderiv  [Not a public function]
%
% First derivative of the output function with respect to the activation function
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

switch This.OutputFn
    case 's4'
        isq = in.^2 ;
        out = This.OutputParams./(1+This.OutputParams^2*isq)^(1/2) - (This.OutputParams^3*isq)/(1+This.OutputParams^2*isq)^(3/2) ;
    
    case 'logistic'
        eterm = min(exp(-This.OutputParams*in),1e+10) ;
        out = ( This.OutputParams*eterm )./( 1+eterm ).^2 ;
        
    case 'tanh'
        out = This.OutputParams*sech( This.OutputParams*in ) ;
        
    case 'linear'
        out = 1 ;
        
    otherwise
        utils.error('nnet','Symbolic differentiation not available for output function of type %s\n',This.OutputFn) ;
end


