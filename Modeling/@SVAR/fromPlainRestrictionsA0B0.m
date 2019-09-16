function this = fromPlainRestrictionsA0B0(VAR, restrictA0, restrictB0, varargin)

ny = size(VAR.A, 1);
nv = size(VAR.A, 3);
Omega = VAR.Omega;

if isnumeric(restrictA0)
    numA0 = size(restrictA0, 3);
else
    numA0 = 1;
end
if isnumeric(restrictB0)
    numB0 = size(restrictB0, 3);
else
    numB0 = 1;
end
numRuns = max([nv, numA0, numB0]);

hereCheckDimensions( );
hereCheckOrderCondition( );

this = SVAR( );
this = populateFromVAR(this, VAR);
this.A0 = nan(ny, ny, numRuns);
this.B0 = nan(ny, ny, numRuns);
this.B = nan(ny, ny, numRuns);
this.Std = ones(1, nv);
this.Rank = repmat(Inf, 1, nv);
this.Method = repmat({'PlainRestrictionsA0B0'}, 1, numRuns);
for v = 1 : nv
    if isnumeric(restrictA0)
        ithRestrictA0 = restrictA0(:, :, min(v, end));
    else
        ithRestrictA0 = restrictA0;
    end

    if isnumeric(restrictB0)
        ithRestrictB0 = restrictB0(:, :, min(v, end));
    else
        ithRestrictB0 = restrictB0;
    end

    [ this.A0(:, :, v), ...
      this.B0(:, :, v), ...
      this.B(:, :, v) ] = hereIdentify( this.Omega(:, :, v), ...
                                        ithRestrictA0, ...
                                        ithRestrictB0 );
end



return


    function hereCheckDimensions( )
        if size(restrictA0, 1)~=ny || size(restrictA0, 2)~=ny
            thisError = { 'SVAR:InvalidSizeA0'
                          'Invalid size of restriction matrix A0' };
            throw( exception.Base(thisError, 'error') );
        end
        if size(B, 1)~=ny || size(B, 2)~=ny 
            thisError = { 'SVAR:InvalidSizeB'
                          'Invalid size of restriction matrix B' };
            throw( exception.Base(thisError, 'error') );
        end
        if (numA0~=1 && numA0~=numRuns) || (numB0~=1 && numB0~=numRuns) || (nv~=1 && nv~=numRuns)
            thisError = { 'SVAR:InvalidNumberOfPages'
                          'Inconsistent number of pages in A0 and B, and number of parameter variants' };
            throw( exception.Base(thisError, 'error') );
        end
        if nv==1 && numRuns>1
            VAR = alter(VAR, nv);
        end
    end%


    function hereCheckOrderCondition( )
        if isnumeric(restrictA0) 
            numA0Free = zeros(1, numA0);
            for ii = 1 : numA0
                numA0Free(ii) = nnz(isnan(restrictA0(:, :, ii)));
            end
        else
            numA0Free = 0;
        end
        if isnumeric(restrictB0)
            for ii = 1 : numB0
                numB0Free(ii) = nnz(isnan(restrictB0(:, :, ii)));
            end
        else
            numB0Free = 0;
        end
        numFree = numA0Free + numB0Free;
        if any(numFree>ny*(ny+1)/2)
            thisError = { 'SVAR:OrderConditionNotSatisfied'
                          'Order condition for SVAR identification not satisfied; insufficient number of restrictions specified' };
            throw(exception.Base(thisError, 'error'));
        end
    end%
end%


%
% Local Functions
%


function [A0, B0, B] = hereIdentify(Omega, restrictA0, restrictB0)
    if isnumeric(restrictA0)
        inxA0Free = isnan(restrictA0);
        numA0Free = nnz(inxA0Free);
    else
        inxA0Free = logical.empty(0);
        numA0Free = 0;
    end
    if isnumeric(restrictB0)
        inxB0Free = isnan(restrictB0);
        numB0Free = nnz(inxB0Free);
    else
        inxB0Free = logical.empty(0);
        numB0Free = 0;
    end
    numFree = numA0Free + numB0Free;
    ab0 = randn(1, numFree);

    return

        function [obj, A0, B0] = objectiveFunc(ab)
            A0 = restrictA0;
            if isnumeric(A0) && numA0Free>0
                A0(inxA0Free) = ab(1:numA0Free);
            end
            B0 = restrictB0;
            if isnumeric(B0) && numB0Free>0
                B0(inxB0Free) = ab(numA0Free+1:end);
            end
            if isnumeric(A0) && isnumeric(B0)
                A0t = transpose(A0);
                B0t = transpose(B0);
                OmegaFromA0B0 = A0\B0*B0t/A0t;
                obj = log(det(OmegaFromA0B0)) + trace(OmegaFromA0B0\Omega);
            elseif isnumeric(A0)
            elseif isnumeric(B0)
            end
        end%
end%

