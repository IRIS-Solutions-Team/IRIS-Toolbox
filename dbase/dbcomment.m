function D = dbcomment(D,M)
% dbcomment  Create model-based comments for database time series entries.
%
% Syntax
% =======
%
%      D = dbcomment(D,M)
%
% Input arguments
% ================
%
% * `D` [ struct ] - Database.
%
% * `M` [ model ] - Model object.
%
% Output arguments
% =================
%
% * `D` [ struct ] - Database where every time series entry is (if possible)
% assigned a comment based on the description of a model variable or
% parameter found in the model object, `M`.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

list = fieldnames(D);
c = get(M,'descript');
for i = 1 : length(list)
    name = list{i};
    if ~isa(D.(name), 'Series') && ~isfield(c,name)
        continue
    end
    try %#ok<TRYNC>
        D.(name) = comment(D.(name),c.(name));
    end
end

end
