%{
% 
% # `databank.redate` ^^(+databank)^^
% 
% {== Redate all time series objects in a database ==}
% 
% 
% ## Syntax 
% 
%     d = databank.redate(d, oldDate, newDate)
% 
% 
% ## Input arguments 
% 
% __`d`__ [ struct ]
% > 
% > Input database with time series objects.
% > 
% 
% __`oldDate`__ [ DateWrapper ]
% > 
% > Base date that will be converted to a new date in all time series objects.
% > 
% 
% __`newDate`__ [ DateWrapper ]
% > 
% > A new date to which the base date `oldDate`
% > will be changed in all time series objects; `newDate` need not be the
% > same frequency as `oldDate`.
% > 
% 
% 
% ## Output arguments 
% 
% __`d`__ [ struct ]
% > 
% > Output database where all time series objects have
% > identical data as in the input database, but with their time dimension
% > changed.
% > 
% 
% 
% ## Options 
% 
% __`zzz=default`__ [ zzz | ___ ]
% > 
% > Description
% > 
% 
% 
% ## Description 
% 
% 
% 
% ## Examples
% 
% ```matlab
% ```
% 
%}
% --8<--



function d = redate(d, oldDate, newDate)

    list = fieldnames(d);
    freq = dater.getFrequency(oldDate);
    inxSeries = structfun(@(x) isa(x, 'Series') && getFrequency(x)==freq, d);
    inxStructs = structfun(@isstruct, d);

    % Cycle over all Series objects
    for i = reshape(find(inxSeries), 1, [])
       d.(list{i}) = redate(d.(list{i}), oldDate, newDate);
    end

    % Call recusively redate(~) on nested databases
    for i = reshape(find(inxStructs), 1, [])
       d.(list{i}) = databank.redate(d.(list{i}), oldDate, newDate);
    end

end%

