function c = speclatexcode(this)
% speclatexcode  Produce LaTeX code for figure object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

c = '';

% Create a figure window, and update the property `This.handle`.
this = myplot(this);

% Create PDF
%------------
% Create PDf for figure handle and the latex command line.
% We need to pass in the top level report object's options that control
% orientation and paper size.
includeGraphics = '';
if ~isempty(this.handle) && ~isempty(get(this.handle, 'children'))
    try
        includeGraphics = mycompilepdf(this, this.hInfo);
    catch Error
        try %#ok<TRYNC>
            close(this.handle);
        end
        utils.warning('report', ...
            ['Error creating this figure: %s.\n', ...
            '\tUncle says: %s'], ...
            this.title, Error.message);
        return
    end
end

% Close figure window or add its handle to the list of open figures
%-------------------------------------------------------------------
if ~isempty(this.handle)
    if this.options.close
        try %#ok<TRYNC>
            close(this.handle);
        end
    else
        addfigurehandle(this, this.handle);
        if ~isempty(this.title)
            % If the figure stays open, add title.
            % TODO: Add also subtitle.
            grfun.ftitle(this.handle, this.title);
        end
    end
end

% Finish LaTeX code
%-------------------
c = [beginsideways(this), beginwrapper(this, 7)];
c = [c, includeGraphics];
c = [c, finishwrapper(this), finishsideways(this)];
c = [c, footnotetext(this)];

end
