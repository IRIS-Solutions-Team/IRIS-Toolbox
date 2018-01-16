function This = set(This,varargin)
% set  [Not a public function]
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

pp = inputParser( );
pp.addRequired('This',@(x) isa(x,'neuron'));
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
    utils.error('neuron', ...
        'This is not a modifiable neuron object property: ''%s''.', ...
        varargin{~found});
end

% Report values that do not pass validation.
if any(~validated)
    utils.error('neuron', ...
        'The value for this property does not pass validation: ''%s''.', ...
        varargin{~validated});
end

% Subfunctions.

%**************************************************************************
    function [Found,Validated] = doSet(UsrQuery,Value)
        
        Found = true;
        Validated = true;
        query = nnet.myalias(UsrQuery);
        
        if isfunc(Value) || isnumericscalar(Value)
            Value = @(x) Value( ) ;
            switch query
                case 'activation'
                    This.ActivationParams ...
                        = arrayfun( Value, This.ActivationParams ) ;
                
                case 'activationlb'
                    This.ActivationLB ...
                        = arrayfun( Value, This.ActivationLB ) ;
                
                case 'activationub'
                    This.ActivationUB ...
                        = arrayfun( Value, This.ActivationUB ) ;

                case 'output'
                    This.OutputParams ...
                        = arrayfun( Value, This.OutputParams ) ;

                case 'outputlb'
                    This.OutputLB ...
                        = arrayfun( Value, This.OutputLB ) ;

                case 'outputub'
                    This.OutputUB ...
                        = arrayfun( Value, This.OutputUB ) ;

                case 'hyper'
                    This.HyperParams ...
                        = arrayfun( Value, This.HyperParams ) ;
                    
                case 'hyperlb'
                    This.HyperLB ...
                        = arrayfun( Value, This.HyperLB ) ;
                
                case 'hyperub'
                    This.HyperUB ...
                        = arrayfun( Value, This.HyperLB ) ;
                    
                case 'userdata'
                    This = userdata(This,Value) ;
                    
                otherwise
                    Found = false ;
                    
            end
        else
            switch query
                case 'activation'
                    This.ActivationParams = Value ;
                    
                case 'activationLB'
                    This.ActivationLB = Value ;

                case 'activationUB'
                    This.ActivationUB = Value ;

                case 'output'
                    This.OutputParams = Value ;
                    
                case 'outputLB'
                    This.OutputLB = Value ;

                case 'outputUB'
                    This.OutputUB = Value ;
                    
                case 'hyper'
                    This.HyperParams = Value ;
                    
                case 'hyperLB'
                    This.HyperLB = Value ;
                    
                case 'hyperUB'
                    This.HyperUB = Value ;
                    
                case 'userdata'
                    This = userdata(This,Value) ;
                    
                otherwise
                    Found = false ;
                    
            end
        end
        
    end % doSet( ).

end