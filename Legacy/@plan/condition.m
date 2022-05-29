function This = condition(This,List,Dates)
% condition  Condition forecast upon the specified variables at the specified dates.
%
% Syntax
% =======
%
%     P = condition(P,List,Dates)
%
% Input arguments
% ================
%
% * `P` [ plan ] - Simulation plan.
%
% * `List` [ cellstr | char ] - List of variables upon which a forecast
% will be conditioned.
%
% * `Dates` [ numeric ] - Dates at which the forecast will be conditioned
% upon the specified variables.
%
% Output arguments
% =================
%
% * `P` [ plan ] - Simulation plan with new conditioning information
% included.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

% Parse required input arguments.
pp = inputParser( );
pp.addRequired('List',@(x) ischar(x) || iscellstr(x));
pp.addRequired('Dates',@isnumeric);
pp.parse(List,Dates);

% Convert char list to cell of str.
if ischar(List)
    List = regexp(List,'[A-Za-z]\w*','match');
end

if isempty(List)
    return
end

%--------------------------------------------------------------------------

Dates = double(Dates);
[Dates,outOfRange] = mydateindex(This,Dates);
if ~isempty(outOfRange)
    % Report invalid dates.
    utils.error('plan', ...
        'Dates out of simulation plan range: %s.', ...
        dat2charlist(outOfRange));
end

nList = numel(List);
valid = true(1,nList);

for i = 1 : nList
    index = strcmp(This.CList,List{i});
    if any(index)
        This.CAnch(index,Dates) = true;
    else
        valid(i) = false;
    end
end

% Report invalid names.
if any(~valid)
    utils.error('plan', ...
        'Cannot condition upon this name: ''%s''.', ...
        List{~valid});
end

end
