function runningDb = newSeries(runningDb, list)

% >=R2019b
%{
arguments
    runningDb {validate.databank}
    list string
end
%}
% >=R2019b

if isempty(list)
    return
end

isDictionary = isa(runningDb, 'Dictionary');
template = Series( );
for n = reshape(list, 1, [ ])
    if isDictionary
        store(runningDb, n, template);
    else
        runningDb.(n) = template;
    end
end

end%

