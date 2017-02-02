function saveasto(fileName, varargin)
% saveasto  Save variables to a mat file under different names.
%
% Syntax
% =======
%
%     saveasto(FileName,'NewName1=',Var1,'NewName2=',Var2,...)
%
%
% Input arguments
% ================
%
% * `FilName` [ char ] - Name of MAT file to which the specified variables
% will be saved.
%
% * `'NewName1'`, `'NewName2'`, ... [ char ] - New names for the variables
% under which they will save to the MAT file.
%
% * `Var1`, `Var2` - Variables saved to the MAT file.
%
%
% Description
% ============
%
%
% Example
% ========
%
% Create two variables, `a` and `b`, and save them under new names, `A5`
% and `B10`, to a mat file named `'myfile.mat'`. Loading the mat file will
% create the variables under their new names.
%
%     a = rand(5);
%     b = rand(10);
%     saveasto('myfile.mat', 'A5=', a, 'B10=', b);
%     clear;
%     load('myfile.mat');
%     whos
%
%     Name       Size            Bytes  Class     Attributes
% 
%     A5         5x5               200  double              
%     B10       10x10              800  double   
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

x = matfile(fileName);

for i = 1 : 2 : numel(varargin)
    newName = regexp(varargin{i},'\w+','once','match');
    if ~ischar(newName) || ~isvarname(newName)
        utils.error('io', ...
            'This is not a valid variable name: ''%s''.', ...
            newName);
    end
    x.(newName) =  varargin{i+1};
end

end