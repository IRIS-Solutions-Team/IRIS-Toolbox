function [Y,Z] = eval(This,X)
% eval  [Not a public function]
%
% Splits transfer function evaluation into evaluation of the composition of
% an activation function and an output function. 
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

switch This.ActivationFn
    case 'bias'
        Y = 1 ;
        Z = 0 ;
    otherwise
        activationParams = NaN(This.nActivationParams,1) ;
        activationParams(This.ActivationIndexLocal) = This.ActivationParams ;
        activationParams(This.ActivationRemovedLocal) = 0.0 ;
        Z = xxActivation(X) ;
        Y = xxOutput(Z) ;
end

    function out = xxActivation(in)
        switch This.ActivationFn
            case 'linear'
                out = in*activationParams(:) ;
            case 'minkovsky'
                tmp = bsxfun(@minus,in,activationParams(:)') ;
                tmp = bsxfun(@power,tmp,This.HyperParams) ;
                tmp = sum(tmp,2) ;
                out = bsxfun(@power,tmp,1/This.HyperParams) ;
        end
    end

    function out = xxOutput(in)
        switch This.OutputFn
            case 's4'
                out = (This.OutputParams.*in)./sqrt(1+This.OutputParams.^2*in.^2) ;
            case 'logistic'
                out = 1./(1+exp(-This.OutputParams.*in)) ;
            case 'tanh'
                atmp = exp(-in*This.OutputParams) ;
                out = (1-atmp)/(1+atmp) ;
            case 'linear'
                out = This.OutputParams*in ;
        end
    end
end



