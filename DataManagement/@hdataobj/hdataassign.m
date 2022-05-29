function this = hdataassign(this, pos, data)
% hdataassign  Assign currently processed data to hdataobj
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

% hdataassign( hData, cols, {y, x, e, ...} )

%--------------------------------------------------------------------------

nPack = length(this.Id);
nData = length(data);

for i = 1 : min(nPack, nData)
    
    if isempty(data{i})
        continue
    end
    
    X = data{i};
    nPer = size(X, 2);
    if this.IsVar2Std
        var2std( );
    end
    
    % Permute X from nName-nPer-nCol to nPer-nCol-nName.
    X = permute(X, [2, 3, 1]);
    
    realId = real(this.Id{i});
    imagId = imag(this.Id{i});
    maxLag = -min(imagId);
    t = maxLag + (1 : nPer);
    
    if this.IncludeLag && maxLag>0
        % Each variable has been allocated an (nPer+maxLag)-by-nCol array. Get
        % pre-sample data from auxiliary lags.
        for j = find(imagId<0)
            jthLag = -imagId(j);
            this.Data.( this.Name{realId(j)} ) ...
                (maxLag+1-jthLag, pos) = X(1, :, j);
        end
        % Assign current dates.
        for j = find(imagId==0)
            this.Data.( this.Name{realId(j)} )(t, pos) = X(:, :, j);
        end
    else
        % Assign current dates only.
        for j = find(imagId==0)
            this.Data.( this.Name{realId(j)} )(:, pos) = X(:, :, j);
        end
    end
end

return




    function var2std( )
        % Convert vectors of vars to vectors of stdevs.
        if isempty(X)
            return
        end
        tol = 1e-15;
        ixNeg = X < tol;
        if any(ixNeg(:))
            X(ixNeg) = 0;
        end
        X = sqrt(X);
    end%
end%
