function This = myplot(This)
% myplot  [Not a public function] Plot figureobj object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

if This.options.visible
    visibleFlag = 'on';
else
    visibleFlag = 'off';
end

%--------------------------------------------------------------------------

This = myplot@report.basefigureobj(This);

% Open new figure window
%------------------------
This.handle = figure('visible',visibleFlag);
% Apply user-supplied figure options one by one so that we catch errors.
figureOpt = This.options.figureopt;
if ~isempty(figureOpt)
    for i = 1 : 2 : length(figureOpt)
        try %#ok<TRYNC>
            name = figureOpt{i};
            name = regexp(name,'\w+','match','once');
            value = figureOpt{i+1};
            set(This.handle,name,value);
        end
    end
end
% Apply styles to this figure only, do not cascade through.
sty = This.options.style;
if ~isempty(sty) && isfield(sty,'figure')
    grfun.style(sty,This.handle,'cascade',false,'warning',false);
end

% Determine subplot division
%----------------------------
nSub = This.options.subplot;
nChild = length(This.children);
nSub = grfun.nsubplot(nSub,nChild);

% Plot all children
%-------------------
% Generate child graphs or empty spaces.
for i = 1 : nChild
    % Both `subplot` and `plot` are object-specific; the method `subplot` does
    % not create any axes objects on emptyobj.
    ch = This.children{i};
    %try
        ax = subplot(ch,nSub(1),nSub(2),i,'box','on');
        plot(ch,ax);
    %catch Err
    %    utils.warning('report:figureobj:myplot', ...
    %        ['Error plotting graph in this figure: %s.\n', ...
    %        '\tUncle says: %s'], ...
    %        This.title,Err.message);
    %end
end

end
