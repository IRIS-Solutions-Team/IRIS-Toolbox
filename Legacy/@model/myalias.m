function query = myalias(query)
% myalias  Aliasing get and set queries
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

if ~isempty(strfind(query, ':'))
    return
end

% Alias filename, fname -> file.
query = regexprep(query, 'f(ile)?name', 'file');
% Alias name, names -> list.
query = regexprep(query, 'names?$', 'list');
% Alias comment, comments, tag, tags.
query = regexprep(query, ...
    'descriptions?|descripts?|descr?|comments?|tags?|annotations?', ...
    'descript');
% Alias param, params, parameter, parameters.
query = regexprep(query, 'param.*', 'param');
% Alias corr, corrs, correlation, correlations
query = regexprep(query, 'corrs?|correlations?', 'corr');
% Alias nalt, nalter.
query = regexprep(query, 'nalt(er)?', 'nalt');
% Alias equation, equations, eqtn, eqtns.
query = regexprep(query, 'eqtns?|equations?', 'eqtn');
% Alias label, labels.
query = regexprep(query, 'labels', 'label');

% Alias dtrend, dtrends, dt.
query = regexprep(query, 'dtrends?', 'dt');

% Alias ss, sstate, steadystate.
query = regexprep(query, 's(teady)?state', 'steady');
query = regexprep(query, '\<ss\>', 'steady');
query = regexprep(query, '\<ssgrowth\>', 'SteadyGrowth');
query = regexprep(query, '\<sslevel\>', 'SteadyLevel');

% Alias level, levels.
query = regexprep(query, 'levels', 'level');
% Alias ss_dt, ss+dt.
query = regexprep(query, '_', '+');

query = regexprep(query, 'alias(es)?', 'alias');

end
