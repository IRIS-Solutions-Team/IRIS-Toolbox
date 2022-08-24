function [ixName, ixTypeName] = userSelection2Index(this, selection, varargin)
% userSelection2TypeIndex  Convert user selection to index on type specific subset.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(selection)
    selection = cell(1, 0);
elseif ischar(selection)
    selection = regexp(selection, '\w+', 'match');
end

if ~iscellstr(selection)
    throw( ...
        exception.Base('Quantity:USER_SELECTION_MUST_CHAR_CELLSTR', 'error') ...
        );
end

ell = lookup(this, selection, varargin{:});
ixName = ell.IxName;
ixValid = ~isnan(ell.PosName);
if any(~ixValid)
    throw( ...
        exception.Base('Quantity:INVALID_NAME_IN_CURRENT_CONTEXT', 'error'), ...
        selection{~ixValid} ...
        );
end

% Reduce the index so that it refers to names of selected types only.
ixTypeName = ixName(ell.IxKeep);

end
