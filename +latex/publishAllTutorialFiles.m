function publishAllTutorialFiles( )

[name, ~, ~, lsFile] = latex.getTutorialInfo( );

for i = 1 : 2 % numel(lsFile)
    [~, fileTitle, fileExt] = fileparts(lsFile{i});
    if isempty(fileExt)
        fileExt = '.m';
    end
    fileName = [fileTitle, fileExt];
    switch fileExt
        case '.m'
            latex.publish(fileName, [ ], 'SuperTitle', name);
        case '.model'
            latex.publish(fileName, [ ], 'SuperTitle', name, 'EvalCode', false);
    end
end

end
