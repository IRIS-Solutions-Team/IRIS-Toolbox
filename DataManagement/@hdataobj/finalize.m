% finalize  Finalize HData output struct
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

function outputDb = finalize(Y)

TIME_SERIES = Series();
MEAN_OUTPUT = "Mean";
MEDIAN_OUTPUT = "Median";
BREAKDOWN_OUTPUT = "Std";
STD_OUTPUT = "Std";
MSE_OUTPUT = "MSE";

outputDb = struct();

if isfield(Y, 'M0') && ~isequal(Y.M0, [ ])
    hereOneOutput('0');
end

if isfield(Y, 'M1') && ~isequal(Y.M1, [ ])
    hereOneOutput('1');
end

if isfield(Y, 'M2') && ~isequal(Y.M2, [ ])
    hereOneOutput('2');
end

return

    function hereOneOutput(X)
        switch X
            case '0'
                prefix = 'Predict';
            case '1'
                prefix = 'Update';
            case '2'
                prefix = 'Smooth';
        end

        outputDb.(prefix) = struct( );
        meanInput = ['M', X];
        medianInput = ['N', X];
        stdInput = ['S', X];
        contInput = ['C', X];
        mseInput = ['Mse', X];

        outputDb.(prefix).(MEAN_OUTPUT) = seriesFromData(Y.(meanInput), "mean");
        if isfield(Y, medianInput)
            outputDb.(prefix).(MEDIAN_OUTPUT) = seriesFromData(Y.(meanInput), "median");
        end
        Y.(meanInput).Data = [];

        if isfield(Y, stdInput)
            outputDb.(prefix).(STD_OUTPUT) = seriesFromData(Y.(stdInput), "std");
            Y.(stdInput).Data = [];
        end

        if isfield(Y, contInput)
            outputDb.(prefix).(BREAKDOWN_OUTPUT) = seriesFromData(Y.(contInput), "breakdown");
            Y.(contInput).Data = [];
        end

        if isfield(Y, mseInput)
            xbVector = Y.(mseInput).XbVector;
            data = Y.(mseInput).Data;
            numDates = size(data, 3);
            numPages = size(data, 4);
            cellData = cell(numDates, numPages);
            for v = 1 : numPages
                for t = 1 : numDates
                    cellData{t, v} = namedmat(data(:, :, t, v), xbVector, xbVector);
                end
            end
            outputDb.(prefix).(MSE_OUTPUT) ...
                = Series(Y.(mseInput).Range(1), cellData);
        end
    end 
end%

