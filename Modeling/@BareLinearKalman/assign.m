function this = assign(this, time, systemMatrices, covarianceMatrices)

if ~isempty(systemMatrices)
    this.SystemMatrices = hereAssign( time, this.SystemMatrices, systemMatrices, ...
                                      this.NAMES_SYSTEM_MATRICES );
end

if ~isempty(covarianceMatrices)
    this.CovarianceMatrices = hereAssign( time, this.CovarianceMatrices, covarianceMatrices, ...
                                          this.NAMES_COVARIANCE_MATRICES );
end

end%


%
% Local Functions
%


function inObject = hereAssign(time, inObject, user, names)

    numTimes = numel(time);
    inxValidDim = true(size(inObject));
    notNeeded = isequal(user, 0);
    if notNeeded
        n = numel(inObject);
    else
        n = min(numel(inObject), numel(user));
    end
    for i = 1 : n
        if notNeeded
            ithUser = zeros(size(inObject{i}, 1), size(inObject{i}, 2));
        else
            if isempty(user{i})
                continue
            end
            ithUser = user{i};
        end
        numPages = size(ithUser, 3);
        if size(inObject{i}, 1)~=size(ithUser, 1) ...
           || size(inObject{i}, 2)~=size(ithUser, 2) ...
           || (numTimes~=numPages && numPages~=1)
            inxValidDim(i) = false;
            continue
        end
        if numPages==1 && numTimes>1
            ithUser = repmat(ithUser, 1, 1, numTimes);
        end
        inObject{i}(:, :, 1+time) = ithUser;
    end

    if all(inxValidDim)
        return
    end

    thisError = { 'BareLinearKalman:InvalidDimensions'
                  'Dimensions of this system or covariancematrix are invalid: %s' };
    throw(exception.Base(thisError, 'error'), names{~inxValidDim});

end%

