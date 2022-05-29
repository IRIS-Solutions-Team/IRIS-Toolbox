function Flag = anyrowname(This)
% anyrowname  [Not a public function] True if user specified at least one row name.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

Flag = ~isempty(This.options.rownames) ...
    && any(~cellfun(@isempty,This.options.rownames));

end
