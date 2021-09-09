% hdatafinal2  Finalize HData output struct.
%
% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2021 IRIS Solutions Team.

function D = hdatafinal2(Y)

TIME_SERIES_CONSTRUCTOR = iris.get('DefaultTimeSeriesConstructor');
TIME_SERIES = TIME_SERIES_CONSTRUCTOR( );

D = struct();

if isfield(Y, 'M0') && ~isequal(Y.M0, [ ])
    hereOneOutput('0');
end

if isfield(Y, 'M1') && ~isequal(Y.M1, [ ])
    hereOneOutput('1');
end

if isfield(Y, 'M2') && ~isequal(Y.M2, [ ])
    hereOneOutput('2');
end

f = fieldnames(D);
if numel(f)==1
    D = D.(f{1});
end

return

    function hereOneOutput(X)
        switch X
            case '0'
                outpName = 'Predict';
            case '1'
                outpName = 'Filter';
            case '2'
                outpName = 'Smooth';
        end

        D.(outpName) = struct( );
        meanField = ['M', X];
        medianField = ['N', X];
        stdField = ['S', X];
        contField = ['C', X];
        mseField = ['Mse', X];

        if isfield(Y, stdField) || isfield(Y, contField) ...
                || isfield(Y, mseField)
            D.(outpName).Mean = seriesFromData(Y.(meanField), "mean");
            if isfield(Y, medianField)
                D.(outpName).Median = seriesFromData(Y.(meanField), "median");
            end
            Y.(meanField).Data = [];
            if isfield(Y, stdField)
                D.(outpName).Std = seriesFromData(Y.(stdField), "std");
                Y.(stdField).Data = [];
            end
            if isfield(Y, contField)
                D.(outpName).Breakdown = seriesFromData(Y.(contField), "breakdown");
                Y.(contField).Data = [];
            end
            if isfield(Y, mseField)
                xbVector = Y.(mseField).XbVector;
                data = Y.(mseField).Data;
                numDates = size(data, 3);
                numPages = size(data, 4);
                cellData = cell(numDates, numPages);
                for v = 1 : numPages
                    for t = 1 : numDates
                        cellData{t, v} = namedmat(data(:, :, t, v), xbVector, xbVector);
                    end
                end
                D.(outpName).MSE = fill(TIME_SERIES, cellData, Y.(mseField).Range(1));
            end
        else
            D.(outpName) = seriesFromData(Y.(meanField), "mean");
            Y.(meanField).Data = [];
        end
    end 
end%

