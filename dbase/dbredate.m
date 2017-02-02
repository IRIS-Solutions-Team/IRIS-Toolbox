function D = dbredate(D,OldDate,NewDate)
% dbredate  Redate all tseries objects in a database.
%
% Syntax
% =======
%
%     D = redate(D,OldDate,NewDate)
%
% Input arguments
% ================
%
% * `D` [ struct ] - Input database with tseries objects.
%
% * `OldDate` [ numeric ] - Base date that will be converted to a new date
% in all tseries objects.
%
% * `NewDate` [ numeric ] - A new date to which the base date `OldDate`
% will be changed in all tseries objects; `newDate` need not be the
% same frequency as `OldDate`.
%
% Output arguments
% =================
%
% * `d` [ struct ] - Output database where all tseries objects have
% identical data as in the input database, but with their time dimension
% changed.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

pp = inputParser( );
pp.addRequired('d',@isstruct);
pp.addRequired('oldDate',@isnumericscalar);
pp.addRequired('newDate',@isnumericscalar);
pp.parse(D,OldDate,NewDate);

%--------------------------------------------------------------------------

list = fieldnames(D);
tseriesInx = structfun(@istseries,D);
structInx = structfun(@isstruct,D);

% Cycle over all tseries objects.
for i = find(tseriesInx.')
   D.(list{i}) = redate(D.(list{i}),OldDate,NewDate);
end

% Call recusively `dbclip` on sub-databases.
for i = find(structInx.')
   D.(list{i}) = dbredate(D.(list{i}),range);
end

end