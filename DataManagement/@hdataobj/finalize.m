% finalize  Finalize HData output struct
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function outputDb = finalize(Y, options)

TIME_SERIES = Series();
MEAN_OUTPUT = iris.mixin.Kalman.MEAN_OUTPUT;
MEDIAN_OUTPUT = iris.mixin.Kalman.MEDIAN_OUTPUT;
CONTRIBS_OUTPUT = iris.mixin.Kalman.CONTRIBS_OUTPUT;
STD_OUTPUT = iris.mixin.Kalman.STD_OUTPUT;
MSE_OUTPUT = iris.mixin.Kalman.MSE_OUTPUT;

outputDb = struct();

if isfield(Y, 'M0') && ~isequal(Y.M0, [ ])
    here_oneOutput('0');
end

if isfield(Y, 'M1') && ~isequal(Y.M1, [ ])
    here_oneOutput('1');
end

if isfield(Y, 'M2') && ~isequal(Y.M2, [ ])
    here_oneOutput('2');
end

return

    function here_oneOutput(X)
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

        if ~options.MedianOnly
            outputDb.(prefix).(MEAN_OUTPUT) = seriesFromData(Y.(meanInput), "mean");
        end
        if isfield(Y, medianInput)
            outputDb.(prefix).(MEDIAN_OUTPUT) = seriesFromData(Y.(meanInput), "median");
        end
        Y.(meanInput).Data = [];

        if isfield(Y, stdInput)
            outputDb.(prefix).(STD_OUTPUT) = seriesFromData(Y.(stdInput), "std");
            Y.(stdInput).Data = [];
        end

        if isfield(Y, contInput)
            outputDb.(prefix).(CONTRIBS_OUTPUT) = seriesFromData(Y.(contInput), "breakdown");
            Y.(contInput).Data = [];
        end

        if isfield(Y, mseInput)
            xbVector = Y.(mseInput).XbVector;
            cellData = covfun.cov2cell(Y.(mseInput).Data, xbVector, xbVector);
            outputDb.(prefix).(MSE_OUTPUT) = Series(Y.(mseInput).Range(1), cellData);
        end
    end 
end%

