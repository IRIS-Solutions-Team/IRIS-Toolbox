%{
% 
% # `databank.newSeries` ^^(+databank)^^
% 
% {== Create new empty series in a databank ==}
% 
% 
% ## Syntax 
% 
%     outputDb = databank.newSeries(inputDb, list)
% 
% 
% ## Input arguments 
% 
% __`inputDb`__ [ struct | Dictionary ]
% > 
% > Input databank within which new time series will be created.
% > 
% 
% __`list`__ [ string ]
% > 
% > List of new time series names; if the already exists in the databank,
% > they will be simply assigned a new empty time series and the previous
% > content will be removed.
% > 
% 
% ## Output arguments 
% 
% __`outputDb`__ [ struct | Dictionary ]
% > 
% > Output databank with the new time series added.
% > 
% 
%}
% --8<--


function runningDb = newSeries(runningDb, list)

% >=R2019b
%(
arguments
    runningDb {validate.databank}
    list string
end
%)
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

