function D = dbredate(D, OldDate, NewDate)
% dbredate  Redate all tseries objects in a database.
%
% __Syntax__
%
%     D = redate(D, OldDate, NewDate)
%
%
% __Input arguments__
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
%
% __Output arguments__
%
% * `D` [ struct ] - Output database where all tseries objects have
% identical data as in the input database, but with their time dimension
% changed.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('dbase/dbredate');
    INPUT_PARSER.addRequired('D', @isstruct);
    INPUT_PARSER.addRequired('OldDate', @(x) DateWrapper.validateDateInput(x) && numel(x)==1);
    INPUT_PARSER.addRequired('NewDate', @(x) DateWrapper.validateDateInput(x) && numel(x)==1);
end

INPUT_PARSER.parse(D, OldDate, NewDate);

%--------------------------------------------------------------------------

list = fieldnames(D);
indexOfSeries = structfun(@(x) isa(x, 'tseries'), D);
indexOfStructs = structfun(@isstruct, D);

% Cycle over all tseries objects.
for i = find(indexOfSeries.')
   D.(list{i}) = redate(D.(list{i}), OldDate, NewDate);
end

% Call recusively `dbclip` on sub-databases.
for i = find(indexOfStructs.')
   D.(list{i}) = dbredate(D.(list{i}), range);
end

end
