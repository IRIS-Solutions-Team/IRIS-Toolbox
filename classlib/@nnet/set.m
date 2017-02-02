function This = set(This,varargin)
% set  Change modifiable nnet object property.
%
% Syntax
% =======
%
%     M = set(M,Request,Value)
%     M = set(M,Request,Value,Request,Value,...)
%
% Input arguments
% ================
%
% * `M` [ nnet ] - Neural network model object.
%
% * `Request` [ char ] - Name of a modifiable neural network model object
% property that will be changed.
%
% * `Value` [ ... ] - Value to which the property will be set.
%
% Output arguments
% =================
%
% * `M` [ nnet ] - Neural network model object with the requested
% property or properties modified.
%
% Valid requests to neural network model objects
% ===============================================
% 
% * `'activation='`, `'activationlb='`, `'activationub='`, `'output='`,
% `'outputlb='`, `'outputub='`, `'hyper='`, `'hyperlb='`, `'hyperub='`
% [ function_handle | numeric ] - Set parameter values or bounds for
% parameters. 

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

pp = inputParser( );
pp.addRequired('This',@(x) isa(x,'nnet'));
pp.addRequired('name',@iscellstr);
pp.addRequired('value',@(x) length(x) == length(varargin(1:2:end-1)));
pp.parse(This,varargin(1:2:end-1),varargin(2:2:end));

%--------------------------------------------------------------------------

% Body
varargin(1:2:end-1) = strtrim(varargin(1:2:end-1));
nArg = length(varargin);
found = true(1,nArg);
validated = true(1,nArg);
for iArg = 1 : 2 : nArg
    [found(iArg),validated(iArg)] = ...
        doSet(lower(varargin{iArg}),varargin{iArg+1});
end

% Report queries that are not modifiable model object properties.
if any(~found)
    utils.error('nnet', ...
        'This is not a modifiable neural network model object property: ''%s''.', ...
        varargin{~found});
end

% Report values that do not pass validation.
if any(~validated)
    utils.error('nnet', ...
        'The value for this property does not pass validation: ''%s''.', ...
        varargin{~validated});
end

% Subfunctions.

%**************************************************************************
    function [Found,Validated,iLayer] = doSet(UsrQuery,Value)
        
        Found = true;
        Validated = true;
        query = nnet.myalias(UsrQuery);
        
        switch query
            case 'activation'
                if isfunc(Value) || isnumericscalar(Value)
                    xxLayerNodeLoop('activation',Value) ;
                else
                    xxLayerNodeIndexLoop('ActivationParams','ActivationIndex',Value) ;
                end
                
            case 'activationlb'
                if isfunc(Value) || isnumericscalar(Value)
                    xxLayerNodeLoop('activationLB',Value) ;
                else
                    xxLayerNodeIndexLoop('ActivationLB','ActivationIndex',Value) ;
                end
                
            case 'activationub'
                if isfunc(Value) || isnumericscalar(Value)
                    xxLayerNodeLoop('activationUB',Value) ;
                else
                    xxLayerNodeIndexLoop('ActivationUB','ActivationIndex',Value) ;
                end
                
            case 'output'
                if isfunc(Value) || isnumericscalar(Value)
                    xxLayerNodeLoop('output',Value) ;
                else
                    xxLayerNodeIndexLoop('OutputParams','OutputIndex',Value) ;
                end
                
            case 'outputlb'
                if isfunc(Value) || isnumericscalar(Value)
                    xxLayerNodeLoop('outputLB',Value) ;
                else
                    xxLayerNodeIndexLoop('OutputLB','OutputIndex',Value) ;
                end
                
            case 'outputub'
                if isfunc(Value) || isnumericscalar(Value)
                    xxLayerNodeLoop('outputUB',Value) ;
                else
                    xxLayerNodeIndexLoop('OutputUB','OutputIndex',Value) ;
                end
                
            case 'hyper'
                if isfunc(Value) || isnumericscalar(Value)
                    xxLayerNodeLoop('hyper',Value) ;
                else
                    xxLayerNodeIndexLoop('HyperParams','HyperIndex',Value) ;
                end
                
            case 'hyperlb'
                if isfunc(Value) || isnumericscalar(Value)
                    xxLayerNodeLoop('hyperLB',Value) ;
                else
                    xxLayerNodeIndexLoop('HyperLB','HyperIndex',Value) ;
                end
                
            case 'hyperub'
                if isfunc(Value) || isnumericscalar(Value)
                    xxLayerNodeLoop('hyperUB',Value) ;
                else
                    xxLayerNodeIndexLoop('HyperUB','HyperIndex',Value) ;
                end
                                
            case 'userdata'
                This = userdata( This, Value );
                
            otherwise
                Found = false;
                
        end
    end % doSet( ).

    function xxLayerNodeLoop(str,Value)
        for iLayer = 1:This.nLayer+1
            for iNode = 1:numel(This.Neuron{iLayer})
                This.Neuron{iLayer}{iNode} ...
                    = set( This.Neuron{iLayer}{iNode}, str, Value ) ;
            end
        end
    end

    function xxLayerNodeIndexLoop(name,indexName,Value,offset)
        if nargin<4
            offset = 0 ;
        end
        for iLayer = 1:This.nLayer+1
            for iNode = 1:numel(This.Neuron{iLayer})
                This.Neuron{iLayer}{iNode}.(name) ...
                    = Value( This.Neuron{iLayer}{iNode}.(indexName) + offset ) ;
            end
        end
    end
end