function d = redate(d, oldDate, newDate)

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

