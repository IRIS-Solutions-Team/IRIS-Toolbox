function outputDatabank = myoutpdata(this, range, inpMean, inpMse, endogenousNames, addToDatabank) %#ok<INUSL>
% myoutpdata  Output data for BaseVAR objects
%
% Backend IRIS function.
% No help provided.

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

template = Series.template( );

try, inpMse; 
    catch, inpMse = [ ]; end %#ok<VUNUS,NOCOM>

endogenousNames = string(endogenousNames);

try
    endogenousNames; %#ok<VUNUS>
    inxTrend = endogenousNames=="!ttrend";
    if any(inxTrend)
        endogenousNames(inxTrend) = "ttrend";
    end
catch %#ok<CTCH>
    endogenousNames = string.empty(1, 0);
end

try, addToDatabank; 
    catch, addToDatabank = struct( ); end %#ok<VUNUS,NOCOM>

%--------------------------------------------------------------------------

nx = size(inpMean, 1);
if ~isempty(range)
    range = range(1) : range(end);
    numPeriods = numel(range);
    start = range(1);
else
    range = zeros(1, 0); %#ok<NASGU>
    numPeriods = 0;
    start = NaN;
end
sizeData3 = size(inpMean, 3);
sizeData4 = size(inpMean, 4);

% Prepare array of std devs if cov matrix is supplied.
if numel(inpMse) == 1 && isnan(inpMse)
    numStd = size(inpMean, 1);
    std = nan(numStd, numPeriods, sizeData3, sizeData4);
elseif ~isempty(inpMse)
    inpMse = timedom.fixcov(inpMse, this.Tolerance.Mse);
    numStd = min(size(inpMean, 1), size(inpMse, 1));
    std = zeros(numStd, numPeriods, sizeData3, sizeData4);
    for i = 1 : sizeData3
        for j = 1 : sizeData4
            for k = 1 : numStd
                std(k, :, i, j) = permute(sqrt(inpMse(k, k, :, i, j)), [1, 3, 2, 4, 5]);
            end
        end
    end
end

outputDatabank = addToDatabank;
for ii = 1 : nx
    name = endogenousNames(ii);
    outputDatabank.(name) = fill( ...
        template, permute(inpMean(ii, :, :, :), [2, 3, 4, 1]), ...
        start, name ...
    );
end

% Include std data in output database
if ~isempty(inpMse)
    outputDatabank = struct( ...
        'mean', outputDatabank, ...
        'std', struct( ) ...
    );
    for ii = 1 : numStd
        name = endogenousNames(ii);
        outputDatabank.std.(name) = fill( ...
            template, permute(std(ii, :, :, :), [2, 3, 4, 1]), ...
            start, name ...
        );
        outputDatabank.std.(name) = trim(outputDatabank.std.(name));
    end
end

end%

