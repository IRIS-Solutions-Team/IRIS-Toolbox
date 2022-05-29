function disp(This,Level)
% disp  Display the structure of a report object.
%
% Help provided in +report/disp.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

try
    Level; %#ok<VUNUS>
catch %#ok<CTCH>
    Level = 0;
end

%--------------------------------------------------------------------------

tab = sprintf('\t');
fprintf('%s',tab(ones(1,1+Level)));
if Level > 0
    fprintf('+');
end

fprintf('%s',shortclass(This));
title = This.title;
if ~isempty(title)
    fprintf(' ''%s''',title);
end
fprintf('\n');

for i = 1 : length(This.children)
    disp(This.children{i},Level+1);
end

if Level == 0
    textfun.loosespace( );
end

end
