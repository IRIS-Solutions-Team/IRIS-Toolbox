function export(this)
% export  Save all export files associated with model object to current working folder.
% 
% Syntax
% =======
%
%     export(m)
%
%
% Input arguments
% ================
%
% * `m` [ model ] - Model object whose export files will be saved.
%
%
% Description
% ============
%
% Function `export` saves all export files associated with the model
% objects to the current working folder. The export files, including their
% file names, are read from the underlying model file at the time of
% calling the `model( )` function. See [`!export`](ModelLang/export) for
% more on export files.
%
% If a file with the same name as one of the export files already exists in
% the current folder, a warning is thrown and the file is overwritten.
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

export(this.Export);

end
