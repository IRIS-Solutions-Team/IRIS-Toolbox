function c = latexcode(this,varargin)
% latexcode  Generate LaTeX code to represent a report object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

c = speclatexcode(this, varargin{:});

if ~isempty(this.options.saveas)
    saveAs = this.options.saveas;
    [~, ~, ext] = fileparts(this.options.saveas);
    if isempty(ext)
        saveAs = [saveAs, '.tex'];
    end
    textual.write(c, saveAs);
end

end%

