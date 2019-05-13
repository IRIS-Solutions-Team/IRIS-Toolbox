% !function  Create exportable m-file function to be saved in working directory.
%
% Syntax
% =======
%
%     !function ... = FunctionName(...)
%         ...
%     !end
%
%
% Description
% ============
%
% You can include in the model file the contents of m-file functions you
% need or want to carry around together with the model; a typical example
% is your own functions used in model equations.
%
% The `!function`...`!end` command is a shortcut to the following
% `!export`...`!end` structure:
%
%     !export(FileName.m)
%         function ... = FunctionName(...)
%             ...
%         end
%     !end
%
% The m-file function are created and saved under the name specified in the
% function definition at the time you load the model using the function
% [`model`](model/model). The contents of the files is are also stored
% within the model objects. You can manually re-create and re-save all
% exportable files by running the function [`export`](model/export).

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.
