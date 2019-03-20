function D = dbredate(D, OldDate, NewDate)
% dbredate  Redate all tseries objects in a database
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

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('dbase.dbredate');
    parser.addRequired('D', @isstruct);
    parser.addRequired('OldDate', @(x) DateWrapper.validateDateInput(x) && numel(x)==1);
    parser.addRequired('NewDate', @(x) DateWrapper.validateDateInput(x) && numel(x)==1);
end
parser.parse(D, OldDate, NewDate);

%--------------------------------------------------------------------------

list = fieldnames(D);
indexOfSeries = structfun(@(x) isa(x, 'TimeSubscriptable'), D);
indexOfStructs = structfun(@isstruct, D);

% Cycle over all TimeSubscriptable objects
for i = find(indexOfSeries(:)')
   D.(list{i}) = redate(D.(list{i}), OldDate, NewDate);
end

% Call recusively redate(~) on sub-databases
for i = find(indexOfStructs(:)')
   D.(list{i}) = dbredate(D.(list{i}), OldDate, NewDate);
end

end%

