function outputData = fourierData(data, opt)

data = data(~opt.InxToExclude, :, :);
[numY, numPeriods, numPages] = size(data);
N = 1 + floor(numPeriods/2);

outputData = nan(numY, numY*numPeriods, numPages);

for idata = 1 : numPages
    fdata = fft(data(:, :, idata).');
    % Sample SGF
    Ii = [ ];
    for j = 1 : N
        Ii = [Ii, fdata(j, :)'*fdata(j, :)]; %#ok<AGROW>
    end
    outputData(:, 1:numY*N, idata) = Ii;
end

%
% Do not divide by 2*pi because we skip mutliplying by 2*pi in L1 in
% freql(~)
%
outputData = outputData/numPeriods;

end%

