function [name, author, descriptPar, lsFile] = getTutorialInfo( )
c = file2char('Contents.m');
c = regexprep(c, '\n%[ ]+\n', '\n%\n');

% Read the name of the tutorial.
[c, name] = removeLine(c);
name = strrep(name, '%', '');
name = strtrim(name);

% Read author(s).
[c, author] = removeLine(c);
author = strrep(author, '&', '');
author = strrep(author, 'by', '');
author = strtrim(author);

% Read description.
[~, descriptPar] = removePar(c);

lsFile = regexp(c, '(?<=%   )[\w\.]+', 'match');
end




function [c, l] = removeLine(c)
e = regexp(c, '[^\n]+\n', 'end', 'once');
l = c(1:e);
c(1:e) = '';
end




function [c, p] = removePar(c)
e = regexp(c, '% [^\s].*?\n%\n', 'end', 'once');
p = c(1:e);
c(1:e) = '';
end