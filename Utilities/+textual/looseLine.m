function looseLine( )
% looseLine  Print blank line if format is loose
%
% __Syntax__
%
%     textual.looseLine( )
%
%
% __Description__
%
%
% __Example__
%
% If format is set to loose (default), `textual.looseLine( )` prints a
% blank line. If format is set to compact, the function does noting.
%
%     >> format loose
%     >> textual.looseLine( )
%
%     >> format compact
%     >> textual.looseLine( )
%     >>
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

try
    isLoose = strcmpi(matlab.internal.display.formatSpacing, 'loose');
catch
    % Legacy test
    isLoose = strcmpi(get(0, 'FormatSpacing'), 'loose');
end

if isLoose
    fprintf('\n');
end

end%
