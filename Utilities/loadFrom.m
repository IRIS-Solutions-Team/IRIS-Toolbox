% loadFrom  Load variables from mat file under different names
%{
% ## Syntax ##
%
%     [var1, var2, ...] = loadFrom(fileName, 'OldName1', 'OldName2', ...)
%
% 
% ## Syntax for MAT Files with One Variable Only ##
%
%     var = loadFrom(fileName)
%
%
% ## Input Arguments ##
%
% __`fileName`__ [ char | string ] -
% Name of the input MAT file (saved previously using the `save` command).
%
% __`matName1`, `matName2`, etc__ [ char | string ] -
% Original names of the variables under which they have been previously
% saved in the MAT file; in MAT files with just one single variable stored
% in them, the name can be omitted.
%
%
% ## Output Arguments ##
%
% __`var`, `var1`, `var2`__ -
% New variables assigned from the MAT file.
%
%
% ## Description ##
%
%
% ## Example ## 
%
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function varargout = loadFrom(fileName, varargin)

x = matfile(fileName);
fullFileName = which(fileName);

if nargin-1==0 && nargout==1
    list = whos('-file', fileName);
    if numel(list)~=1
        thisError = { 'LoadFrom:SingleVariableSyntaxError'
                      'Output name needs to be specified because '
                      'this MAT file contains more than one variables: <%s>' };
        throw(exception.Base(thisError, 'error'), fullFileName);
    end
    varargin = {list.name};
elseif (nargin-1)~=nargout
    thisError = { 'LoadFrom:InputOutputMismatch'
                  'Number of output arguments requested must match '
                  'number of input names given when loading from this MAT file: <%s>' };
    throw(exception.Base(thisError, 'error'), fullFileName);
end

varargout = cell(size(varargin));
for i = 1 : numel(varargout)
    varargout{i} = x.(varargin{i});
end

end%

