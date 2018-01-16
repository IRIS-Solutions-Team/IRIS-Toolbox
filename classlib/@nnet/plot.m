function Ax = plot(varargin)
% plot  Visualize neural network structure.
%
% Syntax
% =======
%
%     Ax = plot(M,...)
%     Ax = plot(Ax,M,...)
%
% Input arguments
% ================
%
% * `Ax` [ hghandle ] - Handle to axes in which the graph will be plotted;
% if not specified, the current axes will used.
%
% * `M` [ nnet ] - Neural network model object.
%
% Output arguments
% =================
%
% * `Ax` [ hghandle ] - Axes handle. 
%
% Options
% ========
%
% * `'Color='` [ *`'blue'`* | `'activation'` | numeric ] - Color of
% connections between neurons can be either a constant blue, a
% shade of blue based on the strength of that connection, or a constant
% thisColor specified as a numeric vector.
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

if ishghandle(varargin{1})
    Ax = varargin{1}(1) ;
    varargin(1) = [ ] ;
    axes(Ax) ; % because text( ) does not accept axes
else
    Ax = gca( ) ;
end
This = varargin{1} ;
varargin(1) = [ ] ;

options = passvalopt('nnet.plot',varargin{:}) ;

% Get plot dimensions
maxH = max(This.Layout)+max(This.Bias) ;
shf = 0 ;

% Get colour space
if isnumeric(options.Color)
    fixColor = options.Color ;
    isFixed = true ;
elseif strcmpi(options.Color,'activation')
    lc = min(abs(get(This,'activation'))) ;
    mc = max(abs(get(This,'activation'))) ;
    if eq(lc,mc)
        options.Color = 'blue' ;
    end
    isFixed = false ;
else
    fixColor = [.1 .1 .8] ;
    isFixed = true ;
end

% Plot inputs
pos = linspace(1,maxH,This.nInput+2) ;
pos = pos(2:end-1) ;
for iInput = 1:This.nInput
    hold on
    scatter(Ax,0,pos(iInput),400,[.2 .7 .2],'s','filled') ;
    th = text(-0.5,pos(iInput),xxFixText(This.Inputs{iInput})) ;
    th.HorizontalAlignment = 'right' ;
    
    % Plot connections
    for iNode = 1:This.Layout(1)
        if intersect(This.Neuron{1}{iNode}.ActivationIndexLocal,iInput)
            doLineColor( ) ;
            hold on
            plot(Ax,[0,This.Neuron{1}{iNode}.Position(1)],[pos(iInput),This.Neuron{1}{iNode}.Position(2)],'Color',thisColor) ;
        end
    end
end
th = text(shf,-1,'Inputs') ;
th.HorizontalAlignment = 'center' ;

% Plot neurons
lb = Inf ;
ub = -Inf ;
for iLayer = 1:This.nLayer
    NN = numel(This.Neuron{iLayer}) ;
    for iNode = 1:NN
        pos = This.Neuron{iLayer}{iNode}.Position ;
        lb = min(lb,pos(2)) ;
        ub = max(ub,pos(2)) ;
        hold on
        if iNode == NN && This.Bias(iLayer)
            thisColor = [.3 .5 .9] ;
        else
            thisColor = [.3 .3 .3] ;
        end
        scatter(Ax,pos(1),pos(2),100,thisColor,'filled') ;
        
        % Plot connections
        if iLayer<This.nLayer
            if This.Bias(iLayer+1)
                NN2 = numel(This.Neuron{iLayer+1})-1 ;
            else
                NN2 = numel(This.Neuron{iLayer+1}) ;
            end
            for iNext = 1:NN2
                if intersect(This.Neuron{iLayer+1}{iNext}.ActivationIndexLocal,iNode)
                    doLineColor( ) ;
                    hold on
                    plot(Ax,[iLayer,iLayer+1],[This.Neuron{iLayer}{iNode}.Position(2),This.Neuron{iLayer+1}{iNext}.Position(2)],'Color',thisColor) ;
                end
            end
        end
    end
    th = text(iLayer+shf,-1,sprintf('Layer %g',iLayer)) ;
    th.HorizontalAlignment = 'center' ;
end

% Plot outputs
pos = linspace(1,maxH,This.nOutput+2) ;
pos = pos(2:3) ;
for iOutput = 1:This.nOutput
    hold on
    scatter(Ax,This.nLayer+1,pos(iOutput),400,[.7,.2,.2],'s','filled') ;
    text(This.nLayer+1.5,pos(iOutput),xxFixText(This.Outputs{iOutput})) ;
    for iNode = 1:numel(This.Neuron{This.nLayer})
        if intersect(This.Neuron{This.nLayer+1}{iOutput}.ActivationIndexLocal,iNode)
            doLineColor( ) ;
            hold on
            plot(Ax,[This.nLayer,This.nLayer+1],[This.Neuron{This.nLayer}{iNode}.Position(2),pos(iOutput)],'Color',thisColor) ;
        end
    end
end
th = text(This.nLayer+1+shf,-1,'Outputs') ;
th.HorizontalAlignment = 'center' ;

% Set scale and clean up
set(Ax,'ylim',[lb-4,ub+2]) ;
set(Ax,'xlim',[-2 This.nLayer+3]) ;
hold off
Ax.XTick = [ ] ;
Ax.YTick = [ ] ;
Ax.Position = [0 0 1 1] ;

    function x = xxFixText(x)
        x = regexprep(x,'_','\\_') ;
        if ~isempty(regexp(x,'\{','once'))
            x = regexprep(x,'\{','_\{t') ;
        else
            x = sprintf('%s%s',x,'_{t}') ;
        end
    end

    function out = xxColor(in)
        in = abs(in) ;
        out = [0 0 1-((in-lc)/(mc-lc))^2] ;
    end

    function doLineColor( )
        if isFixed
            thisColor = fixColor ;
        else
            thisColor = xxColor(This.Neuron{1}{iNode}.ActivationParams(iInput)) ;
        end
        
    end

end






