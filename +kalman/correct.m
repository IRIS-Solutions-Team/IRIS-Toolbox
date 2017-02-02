function [Pe0,A0,Y0,YDelta] = correct(S,Pe0,A0,Y0,Est,D)
% correct  Correct the prediction step for the estimated oolik parameters.
%
% Backed IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

nPOut = S.NPOut;
delta = Est(1:nPOut,:);
nPer = size(S.y1,2);
for t = 2 : nPer
    j = S.yindex(:,t);
    Pe0(j,:,t) = Pe0(j,:,t) - S.M(j,:,t)*Est;
end

if ~S.storePredict
    return
end

% Store the effect of out-of-lik parameters on measurement variables,
% `ydelta`, because we need to correct k-step ahead predictions and
% smoothed estimates. The effect of diffuse init conditions, `init`, will
% have been already accounted for in the estimates of `alpha`.
ny = size(S.Z,1);
nCol = size(A0,2);
YDelta = nan(ny,nCol,nPer);
for t = 1 : nPer
    A0(:,:,t) = A0(:,:,t) + S.Q(:,:,t)*Est;
    YDelta(:,:,t) = S.X(:,:,t)*delta;
    Y0(:,:,t) = S.Z*A0(:,:,t,1) + YDelta(:,:,t);
    if ~isempty(D)
        Y0(:,:,t) = Y0(:,:,t) + D(:,min(t,end));
    end
end

end
