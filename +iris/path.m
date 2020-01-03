function [root, subfolders, rootsRemoved] = path( )
% path  Clean up Matlab path, add the root and all of its subfolders to Matlab path
% 
% Backend IRIS function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

% Get the whole IRIS folder structure; exclude directories starting with an
% _ (on top of +, @, and private, which are excluded by default); the
% current IRIS root is always returned last in `rootsRemoved`
[rootsRemoved, root] = iris.pathManager('cleanup');

% Add the current IRIS folder structure to the temporary search path
addpath(root);

iris.pathManager('addRoot', root);
subfolders = iris.pathManager('addCurrentSubs', root);

end%

