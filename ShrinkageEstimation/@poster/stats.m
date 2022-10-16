% Type `web poster/stats.md` for help on this function
%
% -[IrisToolbox] Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function outputStats = stats(this, theta, logPost, varargin)

isintscalar = @(x) isnumeric(x) && isscalar(x) && round(x)==x;

persistent ip
if isempty(ip)
    isnumericscalar = @(x) isnumeric(x) && isscalar(x);
    islogicalscalar = @(x) islogical(x) && isscalar(x);
    ip = inputParser();
    addParameter(ip, 'hpdicover', 90, @(x) isnumericscalar(x) && x >= 0 && x <= 100);
    addParameter(ip, 'histbins', 50, @(x) isintscalar(x) && x > 0);
    addParameter(ip, 'mddgrid', 0.1:0.1:0.9, @(x) isnumeric(x) && all(x(:) > 0 & x(:) < 1));
    addParameter(ip, 'output', '', @(x) ischar(x) || iscellstr(x) || isstring(x));
    addParameter(ip, 'progress', false, islogicalscalar);
    addParameter(ip, 'chain', true, islogicalscalar);
    addParameter(ip, 'cov', false, islogicalscalar);
    addParameter(ip, 'mean', true, islogicalscalar);
    addParameter(ip, 'median', false, islogicalscalar);
    addParameter(ip, 'mode', false, islogicalscalar);
    addParameter(ip, 'mdd', true, islogicalscalar);
    addParameter(ip, 'std', true, islogicalscalar);
    addParameter(ip, 'hpdi', false, @(x) islogicalscalar(x) || (isnumericscalar(x) && x > 0 && x < 100));
    addParameter(ip, 'hist', true, @(x) islogicalscalar(x) || (isintscalar(x) && x > 0));
    addParameter(ip, 'bounds', false, islogicalscalar);
    addParameter(ip, 'ksdensity', false, @(x) islogicalscalar(x) || isempty(x) || (isintscalar(x) && x > 0));
    addParameter(ip, 'prctile', [ ], @(x) isnumeric(x) && all(x(:) >= 0 & x(:) <= 100));
end
parse(ip, varargin{:});
opt = ip.Results;


here_preprocessOptions();

% Simulated chain has been saved in a collection of mat files
isFile = ischar(theta) || isstring(theta);
if isFile
    theta = char(theta);
end

if opt.mdd && isempty(logPost) && ~isFile
    exception.error([
        "Poster"
        "Vector of log posterior densities must be non-empty "
        "when marginal data density is requested."
    ]);
end

outputStats = struct();
numParams = numel(this.ParameterNames);

if isFile
    inpFile = theta;
    numDraws = NaN;
    saveEvery = NaN;
    here_checkPosteriorFile();
    getThetaFunc = @(I) h5read(inpFile, '/theta', [I, 1], [1, Inf]);
    getLogPostFunc = @() h5read(inpFile, '/logPost', [1, 1], [1, Inf]);
else
    [numParams, numDraws] = size(theta);
end

if opt.mean || opt.cov || opt.std || opt.mdd
    thetaMean = nan(numParams, 1);
    here_calculateMean();
end

if opt.progress
    progress = ProgressBar('[IrisToolbox] @poster/arwm Progress');
end

for i = 1 : numParams
    name = this.ParameterNames(i);

    if isFile
        iTheta = getThetaFunc(i);
    else
        iTheta = theta(i, :);
    end

    if opt.mode || opt.hist
        [histCount, histBins] = hist(iTheta, opt.histbins);
    end

    if opt.chain
        outputStats.chain.(name) = iTheta;
    end
    if opt.mean
        outputStats.mean.(name) = thetaMean(i);
    end
    if opt.median
        outputStats.median.(name) = median(iTheta);
    end
    if opt.mode
        pos = find(histCount == max(histCount));
        % If more than one mode is found, pick the middle one.
        npos = length(pos);
        if npos > 1
            pos = pos(ceil((npos+1)/2));
        end
        outputStats.mode.(name) = histBins(pos);
    end
    if opt.std
        outputStats.std.(name) = ...
            sqrt(sum((iTheta - thetaMean(i)).^2) / (numDraws-1));
    end
    if isnumeric(opt.hpdi) && ~isempty(opt.hpdi)
        outputStats.hpdi.(name) = series.hpdi(iTheta, opt.hpdicover, 2);
    end
    if isnumeric(opt.hist) && ~isempty(opt.hist)
        outputStats.hist.(name) = {histBins, histCount};
    end
    if isnumeric(opt.prctile) && ~isempty(opt.prctile)
        outputStats.prctile.(name) = prctile(iTheta, opt.prctile, 2);
    end
    if opt.bounds
        outputStats.bounds.(name) = [this.Lower(i), this.Upper(i)];
    end
    if ~isequal(opt.ksdensity, false)
        low = this.Lower(i);
        high = this.Upper(i);
        [x, y] = poster.myksdensity(iTheta, low, high, opt.ksdensity);
        outputStats.ksdensity.(name) = [x, y];
    end

    if opt.progress
        update(progress, i/numParams);
    end
end

% Subtract the mean from `Theta`; the original `Theta` is not available
% any longer after this point.
if opt.cov || opt.mdd
    covarMatrix = localllyCalculateCovarMatrix();
end

if opt.cov
    outputStats.cov = covarMatrix;
end

if opt.mdd
    uuu = here_calculateUUU();
    outputStats.mdd = here_calculateMDD();
end

return

    function here_calculateMean()
        if isFile
            for ii = 1 : numParams
                iTheta = getThetaFunc(ii);
                thetaMean(ii) = sum(iTheta) / numDraws;
            end
        else
            thetaMean = sum(theta, 2) / numDraws;
        end
    end%


    function covarMatrix = localllyCalculateCovarMatrix()
        if isFile
            covarMatrix = zeros(numParams);
            for ii = 1 : saveEvery : numDraws
                chunk = min(saveEvery, 1 + numDraws - ii);
                thetaChunk = h5read(inpFile, '/theta', [1, ii], [Inf, chunk]);
                for jj = 1 : numParams
                    thetaChunk(jj, :) = thetaChunk(jj, :) - thetaMean(jj);
                end
                covarMatrix = covarMatrix + thetaChunk * thetaChunk.' / numDraws;
            end
        else
            for ii = 1 : numParams
                theta(ii, :) = theta(ii, :) - thetaMean(ii);
            end
            covarMatrix = theta * theta.' / numDraws;
        end
    end%


    function d = here_calculateMDD()
        % here_calcMdd  Modified harmonic mean estimator of minus the log marginal data
        % density; Geweke (1999).

        % Copyright (c) 2010-2022 IRIS Solutions Team & Troy Matheson.
        logDetSgm = log(det(covarMatrix));

        % Compute g(theta) := f(theta) / post(theta) for all thetas,
        % where f(theta) is given by (4.3.2) in Geweke (1999).
        if isFile
            logPost = getLogPostFunc();
        end
        logG = -(numParams*log(2*pi) + logDetSgm + uuu)/2 - logPost;

        % Normalise the values of the g function by its average so that the
        % later sums does not grow too high. We're adding `avglogg` back
        % again.
        avgLogG = sum(logG) / numDraws;
        logG = logG - avgLogG;

        try
            d = [];
            for pr = reshape(opt.mddgrid, 1, [])
                crit = chi2inv(pr, numParams);
                inx = crit>=uuu;
                if any(inx)
                    tmp = sum(exp(-log(pr) + logG(inx))) / numDraws;
                    d(end+1) = log(tmp) + avgLogG; %#ok<AGROW>
                end
            end
            d = -mean(d);
        catch
            d = NaN;
        end
    end%


    function uuu = here_calculateUUU()
        uuu = nan(1, numDraws);
        invCovarMatrix = inv(covarMatrix);
        if isFile
            pos = 0;
            for ii = 1 : saveEvery : numDraws
                chunk = min(saveEvery, 1 + numDraws - ii);
                thetaChunk = h5read(inpFile, '/theta', [1, ii], [Inf, chunk]);
                for jj = 1 : numParams
                    thetaChunk(jj, :) = thetaChunk(jj, :) - thetaMean(jj);
                end
                for jj = 1 : size(thetaChunk, 2)
                    pos = pos + 1;
                    uuu(pos) = ...
                        thetaChunk(:, jj).' * invCovarMatrix * thetaChunk(:, jj); %#ok<MINV>
                end
            end
        else
            % theta is already demeaned at this point
            for jj = 1 : numDraws
                uuu(jj) = theta(:, jj).' * invCovarMatrix * theta(:, jj); %#ok<MINV>
            end
        end
    end%


    function here_checkPosteriorFile()
        %try
            valid = true;
            % Parameter list.
            paramList = h5readatt(inpFile, '/', 'paramList');
            paramList = regexp(paramList, '\w+', 'match');
            valid = valid && isequal(textual.stringify(paramList), this.ParameterNames);
            % Number of draws.
            numDraws = h5readatt(inpFile, '/', 'numDraws');
            % Save every.
            saveEvery = h5readatt(inpFile, '/', 'saveEvery');
            % Theta dataset.
            thetaInfo = h5info(inpFile, '/theta');
            valid = valid && numDraws == thetaInfo.Dataspace.Size(2);
            % Log posterior dataset.
            logPostInfo = h5info(inpFile, '/logPost');
            valid = valid && numDraws == logPostInfo.Dataspace.Size(2);
        % catch
            % valid = false;
        % end
        if ~valid
            utils.error('poster', ...
                'This is not a valid posterior simulation file: ''%s''.', ...
                inpFile);
        end
    end%


    function here_preprocessOptions()
        if isequal(opt.prctile, true)
            opt.prctile = [10, 90];
        end
        if isequal(opt.hpdi, true)
            opt.hpdi = 90;
        end
        if isequal(opt.hist, true)
            opt.hist = 50;
        end
    end% 
end%

