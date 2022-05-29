function [this, pStar, objStar, proposalCov, hessian, validDiff, infoFromLik] = ...
    estimate(this, data, pri, estOpt, likOpt)
% estimate  Run parameter estimation.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

% Set Optimization Toolbox options structure.
estOpt = irisoptim.myoptimopts(estOpt) ;

%--------------------------------------------------------------------------

np = length(pri.LsParam);

pStar = nan(1, np);
objStar = NaN;
hessian = {zeros(np), zeros(np), zeros(np)};
proposalCov = nan(np);

% Indicator of bounds hit for each parameter: 0 means interior optimum,
% -1 lower bound hit, +1 upper bound hit.
ixBHit = zeros(1, np);

if ~isempty(pri.Init)
    % The vectors `assign` and `stdcorr` are used in `objfunc` to reset
    % the model's parameterisation. This is to make sure that the `obj`
    % handle returned as an output of `estimate` will be not be affected by
    % re-scaling the std devs in the output model object. Make sure the
    % model is solved in the very first run.
    [pStar, objStar, hessian, lmb] ...
        = irisoptim.myoptimize( ...
        @(x) objfunc(x, this, data, pri, estOpt, likOpt),...
        pri.Init, pri.Lower, pri.Upper, estOpt) ;
        
    if isstruct(lmb)
        % Find lower or upper bound hits.
        ixBHit(double(lmb.lower)~=0) = -1;
        ixBHit(double(lmb.upper)~=0) = 1;
    else
        ixBHit(pStar<=pri.Lower) = -1;
        ixBHit(pStar>=pri.Upper) = 1;
    end        
    
    % Fix numerical inaccuracies since `fmincon` sometimes returns
    % values numerically below lower bounds or above upper bounds.
    chkBounds( );
    
    % Initial proposal covariance matrix and contributions of priors to
    % Hessian.
    [hessian, proposalCov, validDiff, infoFromLik] = diffObj( this, data, ...
                                                              pStar, hessian, ...
                                                              ixBHit, pri, estOpt, likOpt );
else
    
    % No parameters to be estimated.
    utils.warning('model:myestimate', ...
        'No parameters to be estimated.');
    
end

return


    function chkBounds( )
        ixBelow = pStar(:)<pri.Lower(:) ;
        ixAbove = pStar(:)>pri.Upper(:) ;
        if any(ixBelow)
            rptBelow = { };
            for ii = find(ixBelow)
                rptBelow = [rptBelow, { ...
                    pStar(ii), pri.Lower(ii)-pStar(ii), pri.LsParam{ii} ...
                    }]; %#ok<AGROW>
            end
            utils.warning('model:myestimate', ...
                ['Final estimate (%g) for this parameter is ', ...
                'numerically below its lower bound by a margin of %g ', ...
                'and will be reset: ''%s''.'], ...
                rptBelow{:});
        end
        if any(ixAbove)
            rptAbove = { };
            for ii = find(ixAbove)
                rptAbove = [rptAbove,{ ...
                    pStar(ii), pStar(ii)-pri.Upper(ii), pri.LsParam{ii} ...
                    }]; %#ok<AGROW>
            end
            utils.warning('model:myestimate', ...
                ['Final estimate (%g) for this parameter is ', ...
                'numerically above its upper bound by a margin of %g ', ...
                'and will be reset: ''%s''.'], ...
                rptAbove{:});
        end
        % Reset the out-of-bounds values.
        pStar(ixBelow) = pri.Lower(ixBelow);        
        pStar(ixAbove) = pri.Upper(ixAbove);
    end
end
