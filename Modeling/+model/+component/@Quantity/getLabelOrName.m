function label = getLabelOrName(this)
% getLabelOrName  Get list of labels and fill in names for empty labels.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

%--------------------------------------------------------------------------

label = this.Label;
ixEmpty = cellfun(@isempty, label);
label(ixEmpty) = this.Name(ixEmpty);

end
