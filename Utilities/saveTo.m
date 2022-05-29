function saveTo(fileName, varargin)
% saveTo  Save variables to mat file under different names
%
% ## Syntax ##
%
%     saveTo(fileName, newName1, var1, newName2, var2, ...)
%
%
% ## Input Arguments ##
%
% __`fileName`__ [ char | string ] -
% Name of MAT file to which the specified variables will be saved.
%
% __`newName1`, `newName2`, etc__ [ char | string ] - 
% New names for the variables under which they will save to the MAT file.
%
% __`var1`, `var2`__ -
% Variables saved to the `fileName` MAT file.
%
%
% ## Description ##
%
%
% ## Example ##
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

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

x = matfile(fileName);
x.Properties.Writable = true;
fullFileName = which(fileName);

for i = 1 : 2 : numel(varargin)
    newName = regexp(varargin{i},'\w+','once','match');
    if ~ischar(newName) || ~isvarname(newName)
        thisError = { 'SaveTo:InvalidName'
                      'When saving to <%s>, this is not a valid variable name: %s' };
        throw(exception.Base(thisError, 'error'), fullFileName, newName);
    end
    x.(newName) = varargin{i+1};
end

end%

