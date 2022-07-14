function s = capitalize(s)

s = regexprep(s, '\<.', '${upper($0)}');

end%

