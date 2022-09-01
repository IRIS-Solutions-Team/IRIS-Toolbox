
function this = assign(this, time, systemMatrices, covarianceMatrices)

    if ~isempty(systemMatrices) && ~isa(systemMatrices, 'missing')
        this.SystemMatrices = local_assign( ...
            time, this.SystemMatrices, systemMatrices ...
            , this.NAMES_SYSTEM_MATRICES ...
        );
    end

    if ~isempty(covarianceMatrices) && ~isa(covarianceMatrices, 'missing')
        this.CovarianceMatrices = local_assign( ...
            time, this.CovarianceMatrices, covarianceMatrices ...
            , this.NAMES_COVARIANCE_MATRICES ...
        );
    end

end%


%
% Local functions
%


function inObject = local_assign(time, inObject, user, names)
    %(
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
            user__ = zeros(size(inObject{i}, 1), size(inObject{i}, 2));
        else
            if isempty(user{i})
                continue
            end
            user__ = user{i};
        end
        numPages = size(user__, 3);
        if size(inObject{i}, 1)~=size(user__, 1) ...
           || size(inObject{i}, 2)~=size(user__, 2) ...
           || (numTimes~=numPages && numPages~=1)
            inxValidDim(i) = false;
            continue
        end
        if numPages==1 && numTimes>1
            user__ = repmat(user__, 1, 1, numTimes);
        end
        inObject{i}(:, :, 1+time) = user__;
    end

    if any(~inxValidDim)
        thisError = [ 
            "LinearSystem:InvalidDimensions"
            "Invalid dimensions of this LinearSystem matrix: %s" 
        ];
        throw(exception.Base(thisError, 'error'), names(~inxValidDim));
    end
    %)
end%

