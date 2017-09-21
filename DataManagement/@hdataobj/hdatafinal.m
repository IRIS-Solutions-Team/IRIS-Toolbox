function D = hdatafinal(Y)
% hdatafinal  Finalize HData output struct.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TIME_SERIES_CONSTRUCTOR = getappdata(0, 'IRIS_TimeSeriesConstructor');
TIME_SERIES = TIME_SERIES_CONSTRUCTOR( );

%--------------------------------------------------------------------------

D = struct( );

if isfield(Y, 'M0') && ~isequal(Y.M0, [ ])
    doOneOutputArea('0');
end

if isfield(Y, 'M1') && ~isequal(Y.M1, [ ])
    doOneOutputArea('1');
end

if isfield(Y, 'M2') && ~isequal(Y.M2, [ ])
    doOneOutputArea('2');
end

f = fieldnames(D);
if length(f)==1
    D = D.(f{1});
end




    function doOneOutputArea(X)
        switch X
            case '0'
                outpName = 'pred';
            case '1'
                outpName = 'filter';
            case '2'
                outpName = 'smooth';
        end
        D.(outpName) = struct( );
        meanField = ['M', X];
        stdField = ['S', X];
        contField = ['C', X];
        mseField = ['Mse', X];
        if isfield(Y, stdField) || isfield(Y, contField) ...
                || isfield(Y, mseField)
            D.(outpName).mean = hdata2tseries(Y.(meanField));
            if isfield(Y, stdField)
                D.(outpName).std = hdata2tseries(Y.(stdField));
            end
            if isfield(Y, contField)
                D.(outpName).cont = hdata2tseries(Y.(contField));
            end
            if isfield(Y, mseField)
                Y.(mseField).Data = permute(Y.(mseField).Data, [3, 1, 2, 4]);
                D.(outpName).mse = fill( ...
                    TIME_SERIES, ...
                    Y.(mseField).Data, ...
                    Y.(mseField).Range(1) ...
                );
            end
        else
            D.(outpName) = hdata2tseries(Y.(meanField));
        end
    end 
end
