function label = getLabelOrInput(this)
% getLabelOrInput  Get list of labels and fill in input equations for empty labels.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

label = this.Label;
ixEmpty = cellfun(@isempty, label);
label(ixEmpty) = this.Input(ixEmpty);

end
