classdef neuron < shared.GetterSetter
    % neuron  [Not a public class definition]
    %
    % Backend IRIS class.
    % No help provided.
    
    % -IRIS Macroeconomic Modeling Toolbox.
    % -Copyright (c) 2007-2017 IRIS Solutions Team.
    
    properties
        ActivationFn@char = '' ;
        ActivationParams = [ ] ;
        ActivationIndex = [ ] ;
        ActivationLB = [ ] ;
        ActivationUB = [ ] ;
        ActivationLBDefault = [ ] ;
        ActivationUBDefault = [ ] ;
        ActivationIndexLocal = [ ] ;
        ActivationRemovedLocal = [ ] ;
        nActivationParams = [ ] ;
        
        OutputFn@char = '' ;
        OutputParams = [ ] ;
        OutputIndex = [ ] ;
        OutputLB = [ ] ;
        OutputUB = [ ] ;
        OutputLBDefault = [ ] ;
        OutputUBDefault = [ ] ;
        
        HyperParams = [ ] ;
        HyperIndex = [ ] ;
        HyperLB = [ ] ;
        HyperUB = [ ] ;
        HyperLBDefault = [ ] ;
        HyperUBDefault = [ ] ;
        
        Position@double = [NaN,NaN] ;
        nAlt = NaN ;
        Bias = false ;
    end
        
    methods
        
        function This = neuron(ActivationFn,OutputFn,nInputs,Position,ActivationIndex,OutputIndex,HyperIndex)
            % neuron  [Not a public function]
            %
            % Backend IRIS function.
            % No help provided.
            
            % -IRIS Macroeconomic Modeling Toolbox.
            % -Copyright (c) 2007-2017 IRIS Solutions Team.
            
            % Activation
            This.ActivationFn = ActivationFn ;
            This.ActivationParams = NaN(nInputs,1) ;
            This.ActivationIndex = ActivationIndex+1:ActivationIndex+numel(This.ActivationParams) ;
            This.ActivationLBDefault = -Inf ;
            This.ActivationUBDefault = Inf ;
            This.ActivationLB = repmat(This.ActivationLBDefault,numel(This.ActivationParams),1) ;
            This.ActivationUB = repmat(This.ActivationUBDefault,numel(This.ActivationParams),1) ;
            This.ActivationIndexLocal = 1:numel(This.ActivationParams) ;
            This.ActivationRemovedLocal = [ ] ;
            This.nActivationParams = numel(This.ActivationParams) ;
            
            % Output
            This.OutputFn = OutputFn ;
            This.OutputParams = NaN ;
            This.OutputIndex = OutputIndex+1:OutputIndex+numel(This.OutputParams) ;
            This.OutputLBDefault = 0 ;
            This.OutputUBDefault = Inf ;
            This.OutputLB = repmat(This.OutputLBDefault,numel(This.OutputParams),1) ;
            This.OutputUB = repmat(This.OutputUBDefault,numel(This.OutputParams),1) ;
            
            % Hyper
            This.HyperParams = NaN ;
            This.HyperIndex = HyperIndex+1 ;
            switch ActivationFn
                case 'minkovsky'
                    This.HyperParams = 2 ;
                otherwise
                    This.HyperParams = 1 ;
            end
            This.HyperLBDefault = 0 ;
            This.HyperUBDefault = Inf ;
            This.HyperLB = repmat(This.HyperLBDefault,numel(This.HyperParams),1) ;
            This.HyperUB = repmat(This.HyperUBDefault,numel(This.HyperParams),1) ;
            
            % Everything else
            This.nAlt = 1 ;
            This.Position = Position ;
            switch ActivationFn
                case 'bias'
                    This.Bias = true ;
                otherwise
                    This.Bias = false ;
            end
        end
        
    end
    
    methods( Hidden )
        function flag = chkConsistency(this)
            flag = chkConsistency@shared.GetterSetter(this) && ...
                chkConsistency@shared.UserDataContainer(this);
        end

        
        
        
        varargout = eval(varargin) ;
        varargout = copy(varargin) ;
        
        varargout = dAdI(varargin) ;
        varargout = dOdA(varargin) ;
    end
end


