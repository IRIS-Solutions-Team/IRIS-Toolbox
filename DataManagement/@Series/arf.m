% >=R2019b
%{
function this = arf(this, A, Z, range, opt)

arguments
    this 
    A (1, :) double
    Z 
    range (1, :) {validate.mustBeProperRange} 

    opt.PrependInput (1, 1) logical = false
    opt.AppendInput (1, 1) logical = false
end
%}
% >=R2019b


% <=R2019a
%(
function this = arf(this, A, Z, range, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addParameter(ip, "PrependInput", false);
    addParameter(ip, "AppendInput", false);
end%
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


range = double(range);
A = reshape(A, 1, []);
order = numel(A) - 1;

if range(1)<=range(end)
    time = "forward";
    extdRange = range(1)-order : range(end);
else
    time = "backward";
    extdRange = range(end) : range(1)+order;
end
numExtdPeriods = length(extdRange);

% Get endogenous data
dataX = getData(this, extdRange);
sizeX = size(dataX);
dataX = dataX(:, :);

% Get exogenous (z) data
if isa(Z, 'Series')
    dataZ = getData(Z, extdRange);
else
    dataZ = Z;
    if isempty(dataZ)
        dataZ = 0;
    end
    dataZ = repmat(dataZ, numExtdPeriods, 1);
end
sizeZ = size(dataZ);
dataZ = dataZ(:, :);

% Expand dataZ or dataX in 2nd dimension if needed
if size(dataZ, 2)==1 && size(dataX, 2)>1
    dataZ = repmat(dataZ, 1, size(dataX, 2));
elseif size(dataZ, 2)>1 && size(dataX, 2)==1
    dataX = repmat(dataX, 1, size(dataZ, 2));
    sizeX = sizeZ;
end

% Normalise polynomial vector
if A(1)~=1
    dataZ = dataZ / A(1);
    A = A / A(1);
end

% Set up time vector
if time=="forward"
    shifts = -1 : -1 : -order;
    timeVec = 1+order : numExtdPeriods;
else
    shifts = 1 : order;
    timeVec = numExtdPeriods-order : -1 : 1;
end


% /////////////////////////////////////////////////////////////////////////
for t = timeVec
    dataX(t, :) = -A(2:end)*dataX(t+shifts, :) + dataZ(t, :);
end
% /////////////////////////////////////////////////////////////////////////


newStart = extdRange(1);

if opt.PrependInput
    [dataX, newStart] = herePrependData(dataX, newStart);
end

if opt.AppendInput
    dataX = hereAppendData(dataX);
end

% Reshape output data back
if numel(sizeX)>2
    dataX = reshape(dataX, [size(dataX, 1), sizeX(2:end)]);
end

% Create the output series from the input series
this = fill(this, dataX, newStart);

return

    function [dataX, newStart] = herePrependData(dataX, newStart)
        %(
        prependData = getDataFromTo(this, -Inf, dater.plus(extdRange(1), -1));
        if size(prependData, 2)==1 && size(dataX, 2)>1
            prependData = repmat(prependData, 1, size(dataX, 2));
        end
        dataX = [prependData; dataX];
        newStart = dater.plus(newStart, -size(prependData, 1));
        %)
    end%

    function dataX = hereAppendData(dataX)
        %(
        appendData = getDataFromTo(this, dater.plus(extdRange(end), +1), Inf);
        if size(appendData, 2)==1 && size(dataX, 2)>1
            appendData = repmat(appendData, 1, size(dataX, 2));
        end
        dataX = [dataX; appendData];
        %)
    end%
end%

