classdef ( InferiorClasses={?matlab.graphics.axis.Axes} ) nnet < shared.UserDataContainer & shared.GetterSetter
    % nnet  Neural network (nnet) Objects and Functions. 
    %
    % nnet methods:
    %
    % Constructor
    % ============
    %
    % * [`nnet`](nnet/nnet) - Create new artificial neural network (nnet) object.
    %
    % Methods
    % ========
    %
    % * [`copy`](nnet/copy) - Create a copy of an artificial neural network
    % * [`disp`](nnet/disp) - Display information about an artificial neural network. 
    % * [`estimate`](nnet/estimate) - Estimate artificial neural network parameters. 
    % * [`eval`](nnet/eval) - Evaluate neural network. 
    % * [`get`](nnet/get) - Query neural network model property. 
    % * [`plot`](nnet/plot) - Visualize neural network structure. 
    % * [`prune`](nnet/prune) - Eliminate weak connections between neurons.
    % * [`set`](nnet/set) - Change modifiable neural network model property. 
    %
    % Getting on-line help on nnet functions
    % ==========================================
    %
    %     help nnet
    %     help nnet/function_name
    %
    
    % -IRIS Macroeconomic Modeling Toolbox.
    % -Copyright (c) 2007-2017 IRIS Solutions Team.
    
    properties
        % cell array of variables
        Inputs@cell = cell(0,1) ;
        Outputs@cell = cell(0,1) ;
        
        ActivationFn@cell = cell(0,1) ;
        OutputFn@cell = cell(0,1) ;
        Bias = false ;
        nAlt ;
        
        Layout = [ ] ;
        
        nPruned ;
        nActivationParams ;
        nOutputParams ;
        nHyperParams ;
        nParams ;
        
        Neuron@cell = cell(0,1) ;

        nInput ;
        nOutput ;
        nLayer ;
    end
    
    methods
        function This = nnet(Inputs,Outputs,Layout,varargin)
            % nnet  Neural network model constructor method.
            %
            % Syntax
            % =======
            %
            %     m =  nnet(Inputs,Outputs,Layout,...)
            %
            % Input arguments
            % ================
            %
            % * `Inputs` [ cellstr | char ] - Variable name or cell array
            % of variable names. 
            % 
            % * `Outputs` [ cellstr | char ] - Variable name or cell array
            % of variable names. 
            % 
            % Both input and output arguments can include lead/lag
            % operators. E.g., nnet({'x{-1}','x{-2}'},'x',...)
            % 
            % * `Layout` [ numeric ] - Vector of integers with length equal
            % to the number of layers such that each element specifies the
            % number of nodes in that layer. 
            %
            % Output arguments
            % =================
            %
            % * `M` [ nnet ] - Neural network model object. 
            %
            % Options
            % ========
            %
            % * `'ActivationFn='` [ *`linear`* | `minkovsky` | cell ] -
            % Specify the activation function for all layers using a
            % valid string, or specify different activation functions
            % for each layer using a cell array of valid strings which has
            % one entry for each layer plus an entry for the output layer. 
            % 
            % * `'Bias='` [ logical | *false* ] - Include bias
            % nodes. Can be set to logical, in which case it affects all
            % layers in the same way; or it can be a vector which specifies
            % which layers should have bias nodes. 
            % 
            % * `'OutputFn='` [ *`logistic`* | `s4` | `tanh` | cell ] - 
            % Specify the output function for all layers using a valid
            % string, or specify different output functions for each layer
            % using a cell array of valid strings which has one entry for
            % each layer plus an entry for the output layer. 
            %
            % Description
            % ============
            % 
            % Implements a wide variety of neural network structures,
            % such as multi-layer feedforward and radial 
            % basis networks, including multi-layer perceptrons. 
            % Recurrent neural networks are unsupported at present.  
            % Transfer functions are the composition of an
            % activation and an output function, as in Duch and Jankowski
            % (1999). Features include: 
            % 
            % * Network training using a variety of optimization methods,
            % including backpropogation. 
            % * Network pruning as in Kaashoek and Van Dijk (2002) to mitigate 
            % overfitting problems. 
            % * Network architecture visualisation. 
            % * Parallel network pruning and training algorithms. 
            % 
            % Examples
            % =========
            % 
            % M = nnet({'x{-1}','x{-2}'},'x',[5 10],'bias=',true,...
            %     'outputFn=',{'logistic','logistic','linear'}) ;
            % 
            % References
            % ===========
            %
            % * Duch, Wlodzislaw; Jankowski, Norbert (1999). "Survey of
            % neural transfer functions," Neural Computing Surveys 2. 
            % 
            % * Gorodkin, J., Hansen, L.K., Krogh, A., Savarer, C., and
            % Winther, O. (1993). "A quantitative study of pruning by
            % optimal brain damage," mimeo. 
            % 
            % * Kaashoek, Johan F., and Van Dijk, Herman K. (2002). "Neural
            % network pruning applied to real exchange rate analysis,"
            % Journal of Forecasting. 
            %
            % -IRIS Macroeconomic Modeling Toolbox.
            % -Copyright (c) 2007-2017 IRIS Solutions Team.
            
            pp = inputParser( ) ;
            pp.addRequired('Inputs',@(x) iscellstr(x) || ischar(x)) ;
            pp.addRequired('Outputs',@(x) iscellstr(x) || ischar(x)) ;
            pp.addRequired('Layout',@(x) isvector(x) && isnumeric(x)) ;
            pp.parse(Inputs,Outputs,Layout) ;
            
            % Superclass constructors
            This = This@shared.UserDataContainer( );
            
            % Construct
            This.Inputs = cellstr(Inputs) ;
            This.Outputs = cellstr(Outputs) ;
            This.Layout = Layout ;
            This.nAlt = 1 ;
            
            This.nLayer = numel(This.Layout) ;
            This.nInput = numel(This.Inputs) ;
            This.nOutput = numel(This.Outputs) ;
            This.nPruned = 0 ;
            
            % Parse options
            options = passvalopt('nnet.nnet',varargin{:});
            if numel(options.Bias) == 1
                options.Bias = true(size(Layout)).*options.Bias ;
            end
            if ischar(options.ActivationFn)
                options.ActivationFn = cellfun(@(x) options.ActivationFn, cell(1,This.nLayer+1), 'UniformOutput', false) ;
            end
            if ischar(options.OutputFn)
                options.OutputFn = cellfun(@(x) options.OutputFn, cell(1,This.nLayer+1), 'UniformOutput', false) ;
            end
            This.ActivationFn = options.ActivationFn ;
            This.OutputFn = options.OutputFn ;
            This.Bias = options.Bias ;
            
            % Initialize layers of neurons
            ActivationIndex = 0 ;
            OutputIndex = 0 ;
            HyperIndex = 0 ;
            Nmax = max(This.Layout) ;
            This.Neuron = cell(This.nLayer+1,1) ;
            % Normal layers first
            for iLayer = 1:This.nLayer
                NN = This.Layout(iLayer) + This.Bias(iLayer) ;
                pos = linspace(Nmax,1,NN) ;
                if iLayer == 1
                    nInput = This.nInput ;
                else
                    nInput = numel(This.Neuron{iLayer-1}) ; %#ok<*PROP>
                end
                % Regular neurons
                This.Neuron{iLayer} = cell(This.Layout(iLayer),1) ;
                for iNode = 1:This.Layout(iLayer)
                    Position = [iLayer,pos(iNode)] ;
                    This.Neuron{iLayer}{iNode} ...
                        = neuron(options.ActivationFn{iLayer},...
                        options.OutputFn{iLayer},...
                        nInput,...
                        Position,...
                        ActivationIndex,OutputIndex,HyperIndex) ;
                    xxUpdateIndex( ) ;
                end
                % Bias neurons
                if options.Bias(iLayer)
                    Position = [iLayer,pos(This.Layout(iLayer)+1)] ;
                    This.Neuron{iLayer}{This.Layout(iLayer)+1} ...
                        = neuron('bias','bias',nInput,Position,...
                        ActivationIndex,OutputIndex,HyperIndex) ;
                    xxUpdateIndex( ) ;
                end
            end
            % Output layer
            iLayer = This.nLayer + 1 ;
            This.Neuron{iLayer} = cell(This.nOutput,1) ;
            for iNode = 1:This.nOutput
                This.Neuron{iLayer}{iNode} ...
                    = neuron(options.ActivationFn{iLayer},...
                    options.OutputFn{iLayer},...
                    This.Layout(This.nLayer)+This.Bias(This.nLayer),...
                    [NaN,NaN],...
                    ActivationIndex,OutputIndex,HyperIndex) ;
                xxUpdateIndex( ) ;
            end
            
            This.nActivationParams = ActivationIndex ;
            This.nOutputParams = OutputIndex ;
            This.nHyperParams = HyperIndex ;
            This.nParams = ActivationIndex + OutputIndex + HyperIndex ;
            
            This = set(This,'hyper',1,'activation',0,'output',1) ;
            
            function xxUpdateIndex( )
                ActivationIndex = ActivationIndex + numel(This.Neuron{iLayer}{iNode}.ActivationIndex) ;
                OutputIndex = OutputIndex + numel(This.Neuron{iLayer}{iNode}.OutputIndex) ;
                HyperIndex = HyperIndex + numel(This.Neuron{iLayer}{iNode}.HyperIndex) ;
            end
        end
        
        varargout = disp(varargin) ;
        varargout = size(varargin) ;
        varargout = set(varargin) ;
        varargout = eval(varargin) ;
        varargout = plot(varargin) ;
        varargout = prune(varargin) ;
        varargout = isnan(varargin) ;
        
        % Destructor method
        function delete(This)
            for iLayer = 1:This.nLayer+1
                for iNode = 1:numel(This.Neuron{iLayer})
                    delete( This.Neuron{iLayer}{iNode} ) ;
                end
            end
        end
    end
    
    methods( Hidden )
        function flag = chkConsistency(this)
            flag = chkConsistency@shared.GetterSetter(this) && ...
                chkConsistency@shared.UserDataContainer(this);
        end

        
        
        
        varargout = copy(varargin) ;
        varargout = rmnan(varargin) ;
        varargout = myrange(varargin) ;
        varargout = mysameio(varargin) ;
        varargout = datarequest(varargin) ;
        varargout = horzcat(varargin) ;
        varargout = vertcat(varargin) ;
        varargout = myfwdpass(varargin) ;
        varargout = bp(varargin) ;
        varargout = maxabs(varargin) ;
    end
    
    methods( Static, Hidden )
        varargout = myalias(varargin)
    end
    
    
end

