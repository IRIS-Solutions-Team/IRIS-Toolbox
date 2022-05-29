function indexNaNSolutions = reportNaNSolutions(this)
% reportNaNSolutions  Throw warnings for parameter variants for which solution does not exist
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

[~, indexNaNSolutions] = isnan(this, 'Solution');

assert( ...
    ~any(indexNaNSolutions), ...
    exception.Base('Model:SolutionNotAvailable', 'warning'), ...
    exception.Base.alt2str(indexNaNSolutions) ...
);

end
