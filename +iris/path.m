% path  Clean up Matlab path, add the root and all of its subfolders to Matlab path
% 
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 IRIS Solutions Team

function [root, subfolders, rootsRemoved] = path(options)

    % Get the whole IRIS folder structure; exclude directories starting with an
    % _ (on top of +, @, and private, which are excluded by default); the
    % current IRIS root is always returned last in `rootsRemoved`
    [rootsRemoved, root] = iris.pathManager('cleanup');

    % Add the current IRIS root folder
    addpath(root);
    iris.pathManager('addRoot', root);

    % Add the first-level subfolders
    subfolders = iris.pathManager('addCurrentSubs', root, options); 

end%

