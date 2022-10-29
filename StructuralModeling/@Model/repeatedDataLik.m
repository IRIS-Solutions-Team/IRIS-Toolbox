
function func = repeatedDataLik(this, inputData, range, varargin)

    domain = "time";
    if ~isempty(varargin)
        if strcmpi(varargin{1}, ["t", "time"])
            domain = "time";
            varargin(1) = [];
        elseif strcmpi(varargin{1}, ["f", "freq", "frequency"])
            domain = "frequency";
            varargin(1) = [];
        end
    end

    baseRange = reshape(double(range), 1, [ ]);

    if domain=="time"
        opt = prepareKalmanOptions2(this, baseRange, varargin{:});
        inputArray = prepareKalmanData(this, inputData, baseRange, opt.WhenMissing);
    else
        opt = prepareFreckleOptions2(this, baseRange, varargin{:});
        inputArray = prepareFreckleData(this, inputData, baseRange, opt.WhenMissing);
    end


    %=========================================================================
    argin = struct( ...
        'InputData', inputArray, ...
        'OutputData', [], ...
        'InternalAssignFunc', [], ...
        'Options', opt ...
    );

    if domain=="time"
        func = @(model) implementKalmanFilter(model, argin);
    else
        func = @(model) implementFreckle(model, argin);
    end
    %=========================================================================

end%

