function flag = checkConsistency(this)
% checkConsistency  Check internal consistency of object properties
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

numEquations = length(this.Input);

flag = length(this.Type)==numEquations ...
       && isnumeric(this.Type) ...
       && length(this.Label)==numEquations ...
       && iscellstr(this.Label) ...
       && length(this.Alias)==numEquations ...
       && iscellstr(this.Alias) ...
       && length(this.Dynamic)==numEquations ...
       && iscell(this.Dynamic) ...
       && length(this.Steady)==numEquations ...
       && iscell(this.Steady) ...
       && length(this.IxHash)==numEquations ...
       && islogical(this.IxHash);

if ~flag
    return
end

% Check index of nonlinear equations.
inxHash = cellfun(@(x) ~isempty(strfind(x, '=#')), this.Input);

flag = isequal(this.IxHash, inxHash);

end%

