function looseLine( )

try
    isLoose = strcmpi(matlab.internal.display.formatSpacing, 'loose');
catch
    isLoose = strcmpi(get(0, 'FormatSpacing'), 'loose');
end

if isLoose
    fprintf('\n');
end

end
