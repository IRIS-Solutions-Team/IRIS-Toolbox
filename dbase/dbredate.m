function D = dbredate(D, OldDate, NewDate)
% dbredate  Redate all time series objects in a database
%
% __Syntax__
%
%     D = dbredate(D, OldDate, NewDate)
%
%
% __Input arguments__
%
% * `D` [ struct ] - Input database with time series objects.
%
% * `OldDate` [ numeric ] - Base date that will be converted to a new date
% in all time series objects.
%
% * `NewDate` [ numeric ] - A new date to which the base date `OldDate`
% will be changed in all time series objects; `newDate` need not be the
% same frequency as `OldDate`.
%
%
% __Output arguments__
%
% * `D` [ struct ] - Output database where all time series objects have
% identical data as in the input database, but with their time dimension
% changed.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('dbase.dbredate');
    parser.addRequired('D', @isstruct);
end
parser.parse(D);

%--------------------------------------------------------------------------

list = fieldnames(D);
inxOfSeries = structfun(@(x) isa(x, 'TimeSubscriptable'), D);
inxOfStructs = structfun(@isstruct, D);

% Cycle over all TimeSubscriptable objects
for i = find(inxOfSeries(:)')
   D.(list{i}) = redate(D.(list{i}), OldDate, NewDate);
end

% Call recusively redate(~) on sub-databases
for i = find(inxOfStructs(:)')
   D.(list{i}) = dbredate(D.(list{i}), OldDate, NewDate);
end

end%

