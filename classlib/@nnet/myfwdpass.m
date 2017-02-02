% myfwdpass  [Not a public function]
%
% Backend IRIS function.
% No help provided.
%
% Syntax
% =======
%
%     M = myfwdpass(M,D,Range,...)
%
% Options
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

function [OutData,Od,Ad] = myfwdpass(This,InData,Range)

if nargout>1
    export = true ;
    Od = cell(1,This.nLayer+2) ;
    Ad = cell(1,This.nLayer+2) ;
    offset = 1 ;
    Ad{offset} = InData ;
    Od{offset} = InData ;
else
    export = false ;
end

% Hidden Layers
for iLayer = 1:This.nLayer
    NN = numel(This.Neuron{iLayer}) ;
    OutData = tseries(Range,Inf(numel(Range),NN)) ;
    Act = tseries(Range,Inf(numel(Range),NN)) ;
    for iNode = 1:NN
        [OutData(Range,iNode),Act(Range,iNode)] ...
            = eval( This.Neuron{iLayer}{iNode}, InData ) ; %#ok<*EVLC>
    end
    if export
        Od{iLayer+offset} = OutData ; 
        Ad{iLayer+offset} = Act ;
    end
    InData = OutData ;
end

% Output layer
iLayer = This.nLayer + 1 ;
OutData = tseries(Range,Inf(numel(Range),This.nOutput)) ;
Act = tseries(Range,Inf(numel(Range),This.nOutput)) ;
for iNode = 1:This.nOutput
    [OutData(Range,iNode),Act(Range,iNode)] ...
        = eval( This.Neuron{iLayer}{iNode}, InData ) ;
    if export
        Od{iLayer+offset} = OutData ; 
        Ad{iLayer+offset} = Act ;
    end
end

end