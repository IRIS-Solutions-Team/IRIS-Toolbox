function [This,pErr] = bp(This,InData,OutData,options)
% bp  [Not a public function]
%
% Backend IRIS function.
% Help for development purposes only.
%
% Syntax
% =======
%
%     M = bp(M,InData,OutData,...)

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

% Parse options
Range = range(InData) ;

if options.abp
    % closed form derivatives
    
    %% Forward pass
    [~,Od,Ad] = myfwdpass(This,InData,Range) ;
    
    %% Backward pass
    offset = 1 ;
    Delta = cell(1,This.nLayer+2) ;
    Delta{This.nLayer+1+offset} = cell(This.nOutput,1) ;
    pErr = ( OutData - Od{This.nLayer+1+offset} ) ;
    for iOutput = 1:This.nOutput
        if abs( pErr(:,iOutput) )<1e-7
            Grad = 0 ;
        else
            Grad = options.NormGradient(pErr(:,iOutput)) ;
        end
        
        Delta{This.nLayer+1+offset}{iOutput} ...
            = dOdA( This.Neuron{This.nLayer+1}{iOutput}, Ad{This.nLayer+1+offset}{:,iOutput} )...
            .*Grad.*pErr(:,iOutput) ;
    end
    
    for iLayer = This.nLayer:-1:1 % layer L-1
        Delta{iLayer+offset} = cell(This.Layout(iLayer),1) ;
        for iNode = 1:This.Layout(iLayer)
            % get weighted deltas from layer L
            s = 0 ;
            for jNode = 1:numel(This.Neuron{iLayer+1})
                s = s + dAdI( This.Neuron{iLayer+1}{jNode}, Ad{iLayer+1}{jNode}, iNode ).*Delta{iLayer+1+offset}{jNode} ;
            end
            Delta{iLayer+offset}{iNode} = dOdA( This.Neuron{iLayer}{iNode}, Ad{iLayer+offset}{:,iNode} ).*s ;
        end
    end
    
    Delta{1} = cell(This.nInput,1) ;
    for iInput = 1:This.nInput
        s = 0 ;
        for jNode = 1:This.Layout(1)
            s = s + dAdI( This.Neuron{1}{jNode}, Ad{1}{jNode}, iInput ).*Delta{2}{jNode} ;
        end
        Delta{1}{iInput} = s ;
    end
    
    %% Update weights
    for iLayer = 1:This.nLayer+1
        for iNode = 1:numel(This.Neuron{iLayer})
            thisNeuron = This.Neuron{iLayer}{iNode} ;
            ind = thisNeuron.ActivationIndexLocal ;
            param = thisNeuron.ActivationParams ;
            for iParam = 1:thisNeuron.nActivationParams
                param( ind(iParam) ) = param( ind(iParam) ) ...
                    - options.learningRate*Delta{iLayer+offset}{iNode}*Od{iLayer-1+offset}{:,iParam} ;
            end
            This.Neuron{iLayer}{iNode}.ActivationParams = param ;
        end
    end
else
    % numerical differentiation
    e = eps^(1/3) ;
    X = [ ] ;
    for iType = 1:numel(options.Select)
        X = [X; get(This,options.Select{iType})] ;
    end
    F0 = objfunc(X,This,InData,OutData,Range,options) ;
    grad = NaN(size(X)) ;
    for ii = 1:numel(X)
        X1 = X ;
        X1(ii) = X1(ii) + e ;
        F1 = objfunc(X1,This,InData,OutData,Range,options) ;
        grad(ii) = (F1 - F0) / e ;
    end
    [~,Pred,This] = objfunc(X - grad*options.learningRate,This,InData,OutData,Range,options) ;
    pErr = OutData - Pred ;
    
end

end

