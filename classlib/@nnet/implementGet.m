function [answ, flag, query] = implementGet(this, query, varargin)
% implementGet  Implement get method for nnet objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

try    
    switch query
        case 'activation'
            answ = NaN(this.nActivationParams,this.nAlt) ;
            for iLayer = 1:this.nLayer+1
                for iNode = 1:numel(this.Neuron{iLayer})
                    answ(this.Neuron{iLayer}{iNode}.ActivationIndex) ...
                        = this.Neuron{iLayer}{iNode}.ActivationParams ;
                end
            end
            flag = true ;
            
        case 'activationlb'
            answ = NaN(this.nActivationParams,1) ;
            for iLayer = 1:this.nLayer+1
                for iNode = 1:numel(this.Neuron{iLayer})
                    answ(this.Neuron{iLayer}{iNode}.ActivationIndex,:) ...
                        = this.Neuron{iLayer}{iNode}.ActivationLB ;
                end
            end
            flag = true ;

        case 'activationub'
            answ = NaN(this.nActivationParams,1) ;
            for iLayer = 1:this.nLayer+1
                for iNode = 1:numel(this.Neuron{iLayer})
                    answ(this.Neuron{iLayer}{iNode}.ActivationIndex,:) ...
                        = this.Neuron{iLayer}{iNode}.ActivationUB ;
                end
            end
            flag = true ;

        case 'activationindex'
            answ = 1:this.nActivationParams ;
            flag = true ;
        
        case 'output'
            answ = NaN(this.nOutputParams,this.nAlt) ;
            for iLayer = 1:this.nLayer+1
                for iNode = 1:numel(this.Neuron{iLayer})
                    answ(this.Neuron{iLayer}{iNode}.OutputIndex,:) ...
                        = this.Neuron{iLayer}{iNode}.OutputParams ;
                end
            end
            flag = true ;
        
        case 'outputlb'
            answ = NaN(this.nOutputParams,1) ;
            for iLayer = 1:this.nLayer+1
                for iNode = 1:numel(this.Neuron{iLayer})
                    answ(this.Neuron{iLayer}{iNode}.OutputIndex,:) ...
                        = this.Neuron{iLayer}{iNode}.OutputLB ;
                end
            end
            flag = true ;
        
        case 'outputub'
            answ = NaN(this.nOutputParams,1) ;
            for iLayer = 1:this.nLayer+1
                for iNode = 1:numel(this.Neuron{iLayer})
                    answ(this.Neuron{iLayer}{iNode}.OutputIndex,:) ...
                        = this.Neuron{iLayer}{iNode}.OutputUB ;
                end
            end
            flag = true ;
            
        case 'hyper'
            answ = NaN(this.nHyperParams,this.nAlt) ;
            for iLayer = 1:this.nLayer+1
                for iNode = 1:numel(this.Neuron{iLayer})
                    answ(this.Neuron{iLayer}{iNode}.HyperIndex,:) ...
                        = this.Neuron{iLayer}{iNode}.HyperParams ;
                end
            end
            flag = true ;
            
        case 'hyperlb'
            answ = NaN(this.nHyperParams,1) ;
            for iLayer = 1:this.nLayer+1
                for iNode = 1:numel(this.Neuron{iLayer})
                    answ(this.Neuron{iLayer}{iNode}.HyperIndex,:) ...
                        = this.Neuron{iLayer}{iNode}.HyperLB ;
                end
            end
            flag = true ;

        case 'hyperub'
            answ = NaN(this.nHyperParams,1) ;
            for iLayer = 1:this.nLayer+1
                for iNode = 1:numel(this.Neuron{iLayer})
                    answ(this.Neuron{iLayer}{iNode}.HyperIndex,:) ...
                        = this.Neuron{iLayer}{iNode}.HyperUB ;
                end
            end
            flag = true ;
                                    
        otherwise
            flag = false ;
    end
catch
    flag = false ;
end

end
