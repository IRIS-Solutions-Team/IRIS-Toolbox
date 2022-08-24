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
% -Copyright (c) 2007-2022 IRIS Solutions Team

function d = redate(d, oldDate, newDate)

persistent parser
if isempty(parser)
    parser = extend.InputParser('databank.redate');
    parser.addRequired('d', @isstruct);
end
parser.parse(d);

list = fieldnames(d);
freq = dater.getFrequency(oldDate);
inxSeries = structfun(@(x) isa(x, 'Series') && getFrequency(x)==freq, d);
inxStructs = structfun(@isstruct, d);

% Cycle over all Series objects
for i = reshape(find(inxSeries), 1, [])
   d.(list{i}) = redate(d.(list{i}), oldDate, newDate);
end

% Call recusively redate(~) on nested databases
for i = reshape(find(inxStruct), 1, [])
   d.(list{i}) = databank.redate(d.(list{i}), oldDate, newDate);
end

end%

