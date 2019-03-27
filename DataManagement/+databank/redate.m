function d = redate(d, oldDate, newDate)
% redate  Redate all time series objects in a database
%
% __Syntax__
%
%     d = databank.redate(d, oldDate, newDate)
%
%
% __Input arguments__
%
% * `d` [ struct ] - Input database with time series objects.
%
% * `oldDate` [ DateWrapper ] - Base date that will be converted to a new
% date in all time series objects.
%
% * `newDate` [ DateWrapper ] - A new date to which the base date `oldDate`
% will be changed in all time series objects; `newDate` need not be the
% same frequency as `oldDate`.
%
%
% __Output arguments__
%
% * `d` [ struct ] - Output database where all time series objects have
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
    parser = extend.InputParser('databank.redate');
    parser.addRequired('d', @isstruct);
end
parser.parse(d);

%--------------------------------------------------------------------------

list = fieldnames(d);
inxOfSeries = structfun(@(x) isa(x, 'TimeSubscriptable'), d);
inxOfStructs = structfun(@isstruct, d);

% Cycle over all TimeSubscriptable objects
for i = find(inxOfSeries(:)')
   d.(list{i}) = redate(d.(list{i}), oldDate, newDate);
end

% Call recusively redate(~) on sub-databases
for i = find(inxOfStructs(:)')
   d.(list{i}) = dbredate(d.(list{i}), oldDate, newDate);
end

end%

