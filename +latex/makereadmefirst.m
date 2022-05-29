function makereadmefirst( )
% makereadmefirst  Populate the read_me_first.m file based on tutorial files.

br = sprintf('\n');

[name, author, descriptPar, lsFile] = latex.getTutorialInfo( );

nFile = numel(lsFile);
sect = cell(1, 2+nFile);

sect{1} = [ ...
    '%% ', name, ' // Read Me First', br...
    '% by ', author, ...
    descriptPar, ...
    ];

% Second section is How to Run...
sect{2} = file2char(fullfile(iris.root( ),'+latex','howtorun.m'));

for i = 1 : nFile;    
    [~, fileTitle, fileExt] = fileparts(lsFile{i});
    if isempty(fileExt)
        fileExt = '.m';
    end
    fileName = [fileTitle, fileExt];
    intro = latex.mfile2intro(fileName);
    
    c = '';
    
    if all(strcmpi(fileExt, '.m'))
        c = [ ...
            c, ...
            intro, br, ...
            br, ...
            '% edit ',fileName, ';', br, ...
            fileName, ';', br, ...
            br, ...
            ]; %#ok<AGROW>
    else
        c = [ ...
            c, ...
            intro, br, ...
            br, ...
            'edit ',fileName, ';', br, ...
            br, ...
            ]; %#ok<AGROW>
    end
    
    sect{2+i} = c;
end

% Make sure there are exactly two line breaks at the end of each section,
% and one line break at the end of the file.
nSect = numel(sect);
for i = 1 : nSect
    sect{i} = regexprep(sect{i}, '\n+$' ,'');
    sect{i} = [sect{i}, br];
    if i<nSect
        sect{i} = [sect{i}, br]; 
    end
end

c = [ sect{:} ];
textual.write(c, 'read_me_first.m');

end
