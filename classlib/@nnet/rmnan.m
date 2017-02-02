function This = rmnan(This)

% rmnan  [Not a public function]  Remove connections between neurons based 
% on activation parameters which are set to NaN. 
%
% This is the only function which changes network layout, and is only
% called by `prune`. 

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

if ~isnan(This)
    return ;
else
    
    for iLayer = 1:This.nLayer+1
        for iNode = 1:numel(This.Neuron{iLayer})
            activationParams = This.Neuron{iLayer}{iNode}.ActivationParams ;
            chk = isnan(activationParams) ;
            nNaN = sum(chk) ;
            if nNaN>0
                % Adjust global count
                This.nActivationParams = This.nActivationParams - nNaN ;
                This.nPruned = This.nPruned + nNaN ;
                
                % Adjust local indices in current node
                This.Neuron{iLayer}{iNode}.ActivationRemovedLocal ...
                    = [This.Neuron{iLayer}{iNode}.ActivationRemovedLocal; ...
                    This.Neuron{iLayer}{iNode}.ActivationIndexLocal(chk)] ;
                This.Neuron{iLayer}{iNode}.ActivationIndexLocal(chk) = [ ] ;
                
                % Adjust global indices and parameters in current node
                This.Neuron{iLayer}{iNode}.ActivationParams(chk) = [ ] ;
                This.Neuron{iLayer}{iNode}.ActivationLB(chk) = [ ] ;
                This.Neuron{iLayer}{iNode}.ActivationUB(chk) = [ ] ;
                indexStart = This.Neuron{iLayer}{iNode}.ActivationIndex(1) ;
                This.Neuron{iLayer}{iNode}.ActivationIndex ...
                    = indexStart:indexStart+numel(This.Neuron{iLayer}{iNode}.ActivationParams)-1 ;
                
                % Adjust global indices in subsequent
                for sNode = iNode+1:numel(This.Neuron{iLayer})
                    This.Neuron{iLayer}{sNode}.ActivationIndex ...
                        = This.Neuron{iLayer}{sNode}.ActivationIndex - nNaN ;
                end
                for sLayer = iLayer+1:This.nLayer+1
                    for sNode = 1:numel(This.Neuron{sLayer})
                        This.Neuron{sLayer}{sNode}.ActivationIndex ...
                            = This.Neuron{sLayer}{sNode}.ActivationIndex - nNaN ;
                    end
                end
            end
        end
    end
    
end

end

