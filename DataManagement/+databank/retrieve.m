function outputDb = mtimes(inputDb, list)
% retrieve  Retrieve selected fields from databan
%{
%% Syntax
%--------------------------------------------------------------------------
%
%     d = d * list
%
%
%% Input Arguments
%--------------------------------------------------------------------------
%
% __`d`__ [ struct | Dictionary ]
%
%     Input database.
%
5
% __`list`__ [ string ] 
%
%     List of entries that will be kept in the output database.
%
%
%% Output Arguments
%--------------------------------------------------------------------------
%
%
% __`d`__ [ struct | Dictionary ] 
%
%     Output database where only the input entries that are in the `list`
%     are included.
%
%
%% Description
%--------------------------------------------------------------------------
%
%
%% Example
%--------------------------------------------------------------------------
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

list = string(list);
if isa(inputDb, 'Dictionary')
    outputDb = retrieve(inputDb, list);
else
    outputDb = rmfield(inputDb, setdiff(keys(inputDb), list));
end

end%

