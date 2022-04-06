function matlab(fileName,D,varargin)

defaults = { ...
    'format','%g',@ischar, ...
};

options = passvalopt(defaults, varargin{:});

try
    D; %#ok<VUNUS>
catch %#ok<CTCH>
    D = [ ];
end

%--------------------------------------------------------------------------

c = fileread(fileName);
command = '\matlab';

allpos = strfind(c,command);
while ~isempty(allpos)
    pos = allpos(1);
    allpos(1) = [ ];
    open1 = pos(1) + length(command);
    close1 = textfun.matchbrk(c,open1);
    if isempty(close1) || c(close1+1) ~= '{'
        dothrowerror( );
    end
    open2 = close1 + 1;
    [close2,expression] = textfun.matchbrk(c,open2);
    if isempty(close2) || c(close2+1) ~= '{'
        dothrowerror( );
    end
    open3 = close2 + 1;
    [close3,format] = textfun.matchbrk(c,open3);
    if isempty(D)
        valueString = '';
    else
        if isempty(format)
            formatString = options.format;
        else
            formatString = ['%',format];
        end
        value = dbeval(D,expression);
        valueString = sprintf(formatString,value);
    end
    replace = ['\matlab{',valueString,'}{',expression,'}{',format,'}'];
    c = [c(1:pos-1),replace,c(close3+1:end)];
    oldLength = close3 - pos + 1;
    newLength = length(replace);
    allpos = allpos + newLength - oldLength;
end

textual.write(c, fileName);

% Nested functions.

%**************************************************************************
    function dothrowerror( )
        x = c(pos-20:pos+20);
        x = textual.convertEndOfLines(x);
        x = strrep(x,char(10),' ');
        utils.error('latex', ...
            'Syntax error in LaTeX \\matlab command: ''...%s...''.',x);
    end
% dothrowerror( ).

end
