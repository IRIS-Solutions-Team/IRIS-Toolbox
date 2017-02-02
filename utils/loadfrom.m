function varargout = loadfrom(FileName,varargin)
% loadfrom  Load variables from a mat file under different names.
%
% Syntax
% =======
%
%     [Var1,Var2,...] = loadfrom(FileName,'OldName1','OldName2',...)
%
%
% Abbreviated syntax (MAT files with one variable only)
% ======================================================
%
%     Var = loadfrom(FileName)
%
%
% Input arguments
% ================
%
% * `FilName` [ char ] - Name of the input MAT file (saved previously using
% the `save` command).
%
% * `'OldName1'`, `'OldName2'`, ... [ char ] - Original names of the
% variables under which they have been previously saved in the MAT file; in
% MAT files with just one single variable stored in them, the name can be
% omitted.
%
%
% Output arguments
% =================
%
% * `Var`, `Var1`, `Var2` - New variables assigned from the MAT file.
%
%
% Description
% ============
%
%
% Example
% ========
%
% Save a variable named `x` to a mat file using the standard `save` command:
%
%     save myfile.mat x;
%
% Load the variable from the mat file into workspace, but under a different
% name:
%
%     y = loadfrom('myfile.mat', 'x');
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Open a matfile object based on the input file name.
x = matfile(FileName);

if isempty(varargin)
    list = whos('-file',FileName);
    if length(list) > 1
        utils.error('io', ...
            ['The input MAT file %s contains more than one variable. ', ...
            'Specify the list of variable name.'], ...
            FileName);
    end
    varargin = {d.name};
end

% Pre-allocate output arguments.
varargout = cell(size(varargin));

% Loop over input names, and assign the mat file variable to the
% corresponding output argument.
for i = 1 : numel(varargin)
    varargout{i} = x.(varargin{i});
end

end