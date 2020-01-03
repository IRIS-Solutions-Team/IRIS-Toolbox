function def = grouping( )
% grouping  Default options for grouping class.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%--------------------------------------------------------------------------

def.eval = {
    'append', true, @islogicalscalar
    };

def.grouping = {
    'IncludeExtras', false, @islogicalscalar
    };

end
