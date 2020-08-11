% databank.newSeries  Create new empty series in a databank
%{
% Syntax
%--------------------------------------------------------------------------
%
%     outputDb = databank.newSeries(inputDb, list)
%
%
% Input Arguments
%--------------------------------------------------------------------------
%
% __`inputDb`__ [ struct | Dictionary ]
%
%>    Input databank within which new time series will be created.
%
%
% __`list`__ [ string ]
%
%>    List of new time series names; if the already exists in the databank,
%>    they will be simply assigned a new empty time series and the previous
%>    content will be removed.
%
%
% Output Arguments
%--------------------------------------------------------------------------
%
% __`outputDb`__ [ struct | Dictionary ]
%
%>    Output databank with the new time series added.
%
%
% Description
%--------------------------------------------------------------------------
%
%
% Example
%--------------------------------------------------------------------------
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 [IrisToolbox] Solutions Team

function runningDb = newSeries(runningDb, list)

arguments
    runningDb {validate.databank}
    list string
end

if isempty(list)
    return
end

isDictionary = isa(runningDb, "Dictionary");
template = Series( );
for n = reshape(list, 1, [ ])
    if isDictionary
        store(runningDb, n, template);
    else
        runningDb.(n) = template;
    end
end

end%

