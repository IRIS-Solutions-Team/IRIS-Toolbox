function D = dbcomment(D,M)
% dbcomment  Create model-based comments for database tseries entries.
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
% * `D` [ struct ] - Database where every tseries entry is (if possible)
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
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

list = fieldnames(D);
c = get(M,'descript');
for i = 1 : length(list)
    name = list{i};
    if ~istseries(D.(name)) && ~isfield(c,name)
        continue
    end
    try %#ok<TRYNC>
        D.(name) = comment(D.(name),c.(name));
    end
end

end