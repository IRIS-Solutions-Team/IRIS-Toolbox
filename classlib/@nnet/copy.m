function That = copy(This)

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

% Copy neurons (pass by reference)
That = This ;
for iLayer = 1:This.nLayer+1
    for iNode = 1:numel(This.Neuron{iLayer}) 
        That.Neuron{iLayer}{iNode} ...
            = copy( This.Neuron{iLayer}{iNode} ) ;
    end
end

% Tell neurons about their forward/backward connections
for iLayer = 1:This.nLayer+1
    % Forward connections
    if iLayer<This.nLayer+1
        for iNode = 1:numel(This.Neuron{iLayer})
            That.Neuron{iLayer}{iNode}.ForwardConnection ...
                = That.Neuron{iLayer+1} ;
        end
    end
    % Backward connections
    if iLayer>1
        for iNode = 1:numel(This.Neuron{iLayer})
            That.Neuron{iLayer}{iNode}.BackwardConnection ...
                = That.Neuron{iLayer-1} ;
        end
    end
end

end






