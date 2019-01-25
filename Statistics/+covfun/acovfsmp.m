function C = acovfsmp(X,Opt)
% acovfsmp  [Not a public function] Sample autocovariance function.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

%--------------------------------------------------------------------------

xSize = size(X);
X = X(:,:,:);
[nPer,nx,nLoop] = size(X);

if isinf(Opt.order)
    Opt.order = nPer - 1;
    if Opt.smallsample
        Opt.order = Opt.order - 1;
    end
end

if Opt.demean
    X = bsxfun(@minus,X,mean(X,1));
end

C = zeros(nx,nx,1+Opt.order,nLoop);
for iLoop = 1 : nLoop
    xi = X(:,:,iLoop);
	if Opt.smallsample
		T = nPer - 1;
	else
		T = nPer;
	end
    C(:,:,1,iLoop) = xi.'*xi / T;
    for i = 1 : Opt.order
        if Opt.smallsample
            T = T - 1;
        end
        C(:,:,i+1,iLoop) = xi(1:end-i,:).'*xi(1+i:end,:) / T;
    end
end

if length(xSize)>3
    C = reshape(C,[nx,nx,1+Opt.order,xSize(3:end)]);
end

end
