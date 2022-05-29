function C = speclatexcode(This)
% speclatexcode  [Not a public function] \LaTeX\ code for include objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Read in the user file.
c = file2char(This.filename,'cellstr');
if ~isinf(This.options.lines)
    c = c(This.options.lines);
end
c = sprintf('%s\n',c{:});
This.userinput = c;

C = speclatexcode@report.userinputobj(This);

end
