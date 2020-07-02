function intro = mfile2intro(file)

[~, ~, ext] = fileparts(file);
if isempty(ext)
    file = [file,'.m'];
end

c = file2char(file);
c = textual.convertEndOfLines(c);

start = regexp(c,'^%%(?!%)', 'start', 'lineanchors');

if isempty(start)
    utils.error('latex:mfile2intro', ...
        'No introduction found in %s.', ...
        file);
end

start = [start,length(c)+1];
intro = c(start(1):start(2)-1);
intro = regexprep(intro,'\n+$','');

% Remove by author.
intro = regexprep(intro, '^%[ ]*[Bb]y.*?\n', '', 'once', 'lineanchors');

end
