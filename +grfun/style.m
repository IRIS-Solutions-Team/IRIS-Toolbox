function style(GS,H,varargin)
% style  Apply styles to graphics object and its descandants.
%
%
% Syntax
% =======
%
%     grfun.style(H,S,...)
%
%
% Input arguments
% ================
%
% * `H` [ numeric ] - Handle to a figure or axes object that will be styled
% together with its descandants (unless `'cascade='` is false).
%
% * `S` [ struct ] - Struct each field of which refers to an
% object-dot-property; the value of the field will be applied to the the
% respective property of the respective object; see below the list of
% graphics objects allowed.
%
%
% Options
% ========
%
% * `'cascade='` [ *`true`* | `false` ] - Cascade through all descendants of the
% object `H`; if false only the object `H` itself will be styled.
%
% * `'warning='` [ *`true`* | `false` ] - Display warnings produced by this
% function.
%
%
% Description
% ============
%
% The style structure, `S`, is constructed of any number of nested
% object-property fields:
%
%     S.object.property = value;
%
% The following is the list of standard Matlab grahics objects the
% top-level fields can refer to:
%
% * `figure`
% * `axes`
% * `title`
% * `xlabel`
% * `ylabel`
% * `zlabel`
% * `line`
% * `bar`
% * `patch`
% * `text`
%
% Special object names
% ---------------------
%
% In addition to standard Matlab graphics object names, you can also refer
% to the following special instances of objects created by IRIS functions:
%
% * `rhsaxes` (an RHS axes object created by `plotyy`)
% * `legend` (represented by an axes object);
% * `plotpred` (line objects with prediction data created by `plotpred`);
% * `highlight` (a patch object created by `highlight`);
% * `highlightcaption` (a text object created by `highlight`);
% * `vline` (a patch object created by `vline`);
% * `vlinecaption` (a text object created by `vline`);
% * `zeroline` (a line object created by `zeroline`).
%
% The property used as the second-level field is simply any regular Matlab
% property of the respective object (see Matlab help on graphics).
%
% The value assigned to a particular property can be either of the
% following:
%
% * a single proper valid value (i.e. a value you would be able to assign
% using the standard Matlab `set` function);
%
% * a cell array of multiple different values that will be assigned to the
% objects of the same type in order of their creation;
%
% * a text string starting with a double exclamation point, `!!`, followed
% by Matlab commands. The commands are expected to eventually create a
% variable named `SET` whose value will then assigned to the respective
% property. The commands have access to variable `H`, a handle to the
% current object.
%
% Setting font size
% ------------------
%
% Font size (in objects like axes, title, etc.) can be set to either a
% numeric scalar (which is the default Matlab behavior) or a character
% string describing a numerical value followed by a percent sign, such as
% `'150%'`. In that case, the font size will be set to the corresponding
% percentage of the current size.
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.


defaults = { 
    'cascade', true, @(x) isequal(x, true) || isequal(x, false) 
    'offset', 0, @(x) isnumeric(x) && isscalar(x)
    'warning', true, @(x) isequal(x, true) || isequal(x, false)
};

opt = passvalopt(defaults, varargin{:});


% Swap style struct and graphic handle if needed.
if all(ishghandle(GS))
    [GS, H] = deal(H, GS);
end

%--------------------------------------------------------------------------

if ischar(GS)
    % Called with a file name.
    % Remove extension.
    [fpath, ftitle] = fileparts(GS);
    GS = runGsf(fullfile(fpath, ftitle), @run);
elseif iscellstr(GS) && length(GS)==1
    % Called directly with commands.
    GS = strtrim(GS{1});
    GS = strrep(GS,'"','''');
    if ~isempty(GS)
        if GS(end) ~= ';'
            GS(end+1) = ';';
        end
        GS = runGsf(GS,@eval);
    end
end

for i = H(:).'
    if ~ishghandle(i)
        continue
    end
    switch lower( get(i, 'type') )
        case 'figure'
            styleFigure(i,GS,opt);
        case {'axes', 'legend'} % HG2 legends are not axes objects.
            styleAxes(i,GS,opt);
        otherwise
            utils.error('grfun:style', ...
                'Style can be applied only to figures or axes.');
    end
end

end




function d = runGsf(gsf, func)
% Run graphic style file and create graphic style database.
axes = [ ];
figure = [ ];
label = [ ];
line = [ ];
title = [ ];
func(gsf);
d = struct( );
d.axes = axes;
d.figure = figure;
d.label = label;
d.line = line;
d.title = title;
end




function applyTo(H, D, Field, Opt)
H0 = H;
H = findobj(H,'flat','-not','userData','excludeFromStyle');
if isempty(H)
    return
end

% Make fieldnames in the style struct case-insensitive.
list = fieldnames(D);
index = strcmpi(Field,list);
if ~any(index)
    return
end
D = D.(list{index});

nh = length(H);
list = fieldnames(D);
for i = 1 : length(list)
    x = D.(list{i});
    if ~iscell(x)
        x = {x};
    end
    nx = numel(x);
    name = regexprep(list{i},'_*$','');
    for j = 1 : nh
        value = x{1+rem(j-1+Opt.offset,nx)};
        if isequal(value, @auto)
            continue
        end
        try
            if ischar(value) && strncmp(strtrim(value),'!!',2)
                % Execture style processor.
                value = grfun.mystyleprocessor(H(j),value);
            end
            set(H(j), name, value);
        catch exc
            flag = handleExceptions(H(j), name, value);
            if ~flag && Opt.warning
                utils.warning('grfun:style',...
                    ['Error setting this %s property: %s.\n', ...
                    '\tUncle says: %s'],...
                    Field,name, exc.message);
            end
        end
    end
end
end




function styleFigure(h, d, opt)
if isempty(h)
    return
end
h = h(:)';
applyTo(h,d,'figure',opt);
if opt.cascade
    for h = h
        %{
            % Find all children with titles, and style the titles.
            obj = findobj(i,'-property','title');
            xxtitle(obj(:).',d,options);
        %}
        
        % HG2: Find all legend objets.
        lg = findobj(h,'type','legend');
        applyTo(lg,d,'legend',opt);
        
        % Find all axes.
        obj = findobj(h,'type','axes');
        styleAxes(obj(:).',d,opt);
    end
end
end




function styleAxes(H,D,Opt)
if isempty(H)
    return
end

% HG1: Find all legend axes, and apply the legend style to them. Do not
% cascade through the legend axes.
lg = findobj(H,'flat','Tag','legend');
applyTo(lg,D,'legend',Opt);

% Find the remaining regular axes. Cascade through them if requested by
% the user.
H = findobj(H,'flat','-not','Tag','legend');
H = H(:).';
applyTo(H(end:-1:1),D,'axes',Opt);

% First, objects that can only have one instance within each parent
% axes object. These are considered part of the axes and are styled
% even if cascade is false.
rhsPeer = [ ];
for iH = H
    % Check if this axes has a plotyy peer.
    iPeer = getappdata(iH,'graphicsPlotyyPeer');
    if ~isempty(iPeer) && strcmp(get(iH,'yAxisLocation'),'right')
        % The current `iH` is an RHS peer. It will be styled first together with
        % its LHS peer, and then separately by using an `rhsaxes` field if it
        % exist.
        rhsPeer(end+1) = iH; %#ok<AGROW>
        continue
    end
    
    jH = [iPeer,iH];
    applyTo(jH,D,'axes',Opt);
    
    % Associates of axes objects.
    xLabelObj = get(iH,'xlabel');
    yLabelObj = get(iH,'ylabel');
    zLabelObj = get(iH,'zlabel');
    titleObj = get(iH,'title');
    if ~isempty(iPeer)
        xLabelObj(end+1) = get(iPeer,'xLabel'); %#ok<AGROW>
        yLabelObj(end+1) = get(iPeer,'yLabel'); %#ok<AGROW>
        zLabelObj(end+1) = get(iPeer,'zLabel'); %#ok<AGROW>
        titleObj(end+1) = get(iPeer,'title'); %#ok<AGROW>
    end
    applyTo(xLabelObj,D,'xLabel',Opt);
    applyTo(yLabelObj,D,'yLabel',Opt);
    applyTo(zLabelObj,D,'zLabel',Opt);
    applyTo(titleObj,D,'title',Opt);
    
    if ~Opt.cascade
        continue
    end
    
    % Find handles to all line objects except those created by
    % `zeroline`, `vline`, and the prediction data plotted by
    % `plotpred`.
    lineObj = findobj(jH,'type','line', ...
        '-and','-not','tag','hline', ...
        '-and','-not','tag','zeroline', ...
        '-and','-not','tag','vline', ...
        '-and','-not','tag','plotpred');
    applyTo(lineObj(end:-1:1).',D,'line',Opt);
    
    % Find handles to prediction data lines created by `plotpred`.
    plotPredObj = findobj(jH,'type','line','tag','plotpred');
    applyTo(plotPredObj.',D,'plotpred',Opt);
    
    % Find handles to zerolines and hlines; do not revert the order of handles.
    zeroLineObj = findobj(jH,'type','line','tag','zeroline');
    applyTo(zeroLineObj.',D,'zeroline',Opt);
    hLineObj = findobj(jH,'type','line','tag','hline');
    applyTo(hLineObj.',D,'zeroline',Opt);
    
    % Find handles to vlines. Do not revert the order of handles; vline objects
    % are now patches, not lines any more.
    % vLineObj = findobj(jH,'type','line','tag','vline');
    vLineObj = findobj(jH,'type','patch','tag','vline');
    applyTo(vLineObj.',D,'vline',Opt);
    
    % Bar graphs.
    barObj = findobj(jH,'-property','barWidth');
    applyTo(barObj(end:-1:1).',D,'bar',Opt);
    
    % Stem graphs.
    stemObj = findobj(jH,'type','stem');
    applyTo(stemObj(end:-1:1).',D,'stem',Opt);
    
    % Find handles to all patches except highlights and fancharts.
    patchObj = findobj(jH,'type','patch', ...
        '-and','-not','tag','highlight', ...
        '-and','-not','tag','fanchart');
    applyTo(patchObj(end:-1:1).',D,'patch',Opt);
    
    % Find handles to highlights. Do not revert the order of
    % handles.
    highlightObj = findobj(jH,'type','patch','tag','highlight');
    applyTo(highlightObj.',D,'highlight',Opt);
    
    % Find handles to fancharts. Do not revert the order of
    % handles.
    fanchartObj = findobj(jH,'type','patch','tag','fanchart');
    applyTo(fanchartObj.',D,'fanchart',Opt);
    
    % Find handles to all text objects except zeroline captions and
    % highlight captions.
    textObj = findobj(jH,'type','text', ...
        '-and','-not','tag','zeroline-caption', ...
        '-and','-not','tag','vline-caption');
    applyTo(textObj(end:-1:1).',D,'text',Opt);
    
    % Find handles to vline-captions and highlight-captions.
    vLineCaptionObj = findobj(jH,'tag','vline-caption');
    applyTo(vLineCaptionObj(end:-1:1).',D,'vlinecaption',Opt);
    highlightCaptionObj = findobj(jH,'tag','highlight-caption');
    applyTo(highlightCaptionObj(end:-1:1).',D, ...
        'highlightcaption',Opt);
    
end

% Apply the `rhsaxes` field (if it exists) to RHS peers in `plotyy` graphs.
% These have been applied the regular `axes` field in the step above.
for iPeer = rhsPeer
    applyTo(iPeer,D,'rhsaxes',Opt);
end
end




function flag = handleExceptions(h, name, value)
flag = true;

if strcmpi(name, 'fontsize') ...
        && ~isempty(value) && ischar(value) ...
        && strncmp(flip(strtrim(value)), '%', 1)
    setFontSize( );
    return
    
elseif strncmpi(flip(name), flip('color'), 5) ...
        && (ischar(value) || isa(value, 'function_handle'))
    setColor( );
    return
    
elseif strcmpi(name, 'excludefromlegend') && isequal(value, true)
    grfun.excludefromlegend(h);
    return
end


hType = get(h,'type');
hTag = get(h,'tag');
switch hType
    case 'axes'
        handleExceptionsInAxes( );
        
    case 'patch'
        switch lower(name)
            case 'basecolor'
                if strcmpi(get(h,'tag'),'fanchart')
                    white = get(h,'userData');
                    faceColor = get(h,'faceColor');
                    if ischar(faceColor) && strcmpi(faceColor,'none')
                        grfun.excludefromlegend(h);
                    else
                        faceColor = white*[1,1,1] + (1-white)*value;
                    end;
                    set(h,'faceColor',faceColor);
                end
                
            case 'color'
                % Vline objects used to be lines, now they are patches (zero width); see
                % remarks in `grfun.vline`.
                if strcmpi(hTag,'vline')
                    set(h,'edgeColor',value);
                end
                
            otherwise
                flag = false;
        end
end

return




    function setFontSize( )
        value = sscanf(value, '%g');
        try
            old = get(h, 'FontSize');
            new = old * value/100;
            set(h, 'fontSize', new);
        catch
            flag = false;
        end
    end




    function setColor( )
        if isa(value, 'function_handle')
            value = func2str(value);
        end
        switch lower(value)
            case {'first', 'blue'}
                value = [0, 0.447, 0.741];
            case {'second', 'orange'}
                value = [0.85, 0.325, 0.098];
            case {'third', 'yellow'}
                value = [0.929, 0.694, 0.125];
            case {'fourth', 'purple'}
                value = [0.494, 0.184, 0.556];
            case {'fifth', 'green'}
                value = [0.4660, 0.6740, 0.1880];
            otherwise
                flag = false;
        end
        if flag
            try
                set(h, name, value);
            catch
                flag = false;
            end
        end
    end




    function handleExceptionsInAxes( )
        switch lower(name)
            case 'yaxislocation'
                if strcmpi(value,'either')
                    grfun.axisoneitherside(h, 'y');
                end
                
            case 'xaxislocation'
                if strcmpi(value,'either')
                    grfun.axisoneitherside(h, 'x');
                end
                
            case 'yticklabelformat'
                yTick = get(h, 'yTick');
                yTickLabel = cell(size(yTick));
                for i = 1 : length(yTick)
                    yTickLabel{i} = sprintf(value, yTick(i));
                end
                set(h,'yTickLabel',yTickLabel, ...
                    'yTickMode','Manual', ...
                    'yTickLabelMode','Manual');
                
            case 'tight'
                if isequal(value, true) || isequal(lower(value), 'on')
                    visual.backend.setAxesTight(h);
                end
                
            case 'clicktocopy'
                if isequal(value, true)
                    grfun.clicktocopy(h);
                end
                
            case 'highlight'
                if isequal(value, true)
                    grfun.highlight(h, value);
                end
                
            case 'zeroline'
                if isequal(value, true)
                    grfun.zeroline(h, value);
                end
                
            case 'vline'
                grfun.vline(h, logical2onoff(value));
                
            case 'grid'
                value = logical2onoff(value);
                set(h, 'XGrid', value, 'YGrid', value);
                
            otherwise
                flag = false;
        end
    end
end




function x = logical2onoff(x)
if isequal(x, true)
        x = 'On';
elseif isequal(x, false)
        x = 'Off';
end
end
    
