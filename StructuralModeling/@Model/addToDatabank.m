function d = addToDatabank(what, this, d, varargin)

if nargin<3
    d = struct( );
end

%( Input parserk
persistent pp
if isempty(pp)
    pp = extend.InputParser('model/addToDatabank');
    pp.KeepUnmatched = true;
    addRequired(pp, 'what', @(x) isstring(x) || ischar(x) || iscellstr(x));
    addRequired(pp, 'model', @(x) isa(x, 'model'));
    addRequired(pp, 'databank', @validate.databank);
end
%)
parse(pp, what, this, d);

%--------------------------------------------------------------------------

for what__ = reshape(strip(string(what)), 1, [ ]);
    lenWhat__ = length(what__);
    if startsWith(what__, "parameters", "ignoreCase", true)
        addParameters( );
    elseif startsWith(what__, "std", "ignoreCase", true)
        addStd( );
    elseif startsWith(what__, "nonzeroCorr", "ignoreCase", true)
        addZeroCorr = false;
        addCorr(addZeroCorr);
    elseif startsWith(what__, "corr", "ignoreCase", true)
        addZeroCorr = true;
        addCorr(addZeroCorr);
    elseif startsWith(what__, "shock", "ignoreCase", true)
        addShocks( );
    elseif startsWith(what__, "default", "ignoreCase", true)
        addParameters( );
        addStd( );
        addZeroCorr = false;
        addCorr(addZeroCorr);
    else
        throw( ...
            exception.Base('Model:InvalidQuantityType', 'error'), ...
            what__ ...
        );
    end
end

return


    function addParameters( )
        ixp = this.Quantity.Type==4;
        for ii = find(ixp)
            name__ = this.Quantity.Name{ii};
            value__ = permute(this.Variant.Values(:, ii, :), [1, 3, 2]);
            d.(name__) = value__;
        end
    end%


    function addStd( )
        listOfStdNames = getStdNames(this.Quantity);
        ne = numel(listOfStdNames);
        vecStd = this.Variant.StdCorr(:, 1:ne, :);
        for ii = 1 : ne
            name__ = listOfStdNames{ii};
            value__ = permute(vecStd(1, ii, :), [2, 3, 1]);
            d.(name__) = value__;
        end
    end%


    function addCorr(addZeroCorr)
        ne = nnz(this.Quantity.Type==31 | this.Quantity.Type==32);
        namesCorr = getCorrNames(this.Quantity);
        valuesCorr = this.Variant.StdCorr(:, ne+1:end, :);
        inxCorrAllowed = this.Variant.IndexOfStdCorrAllowed(ne+1:end);
        namesCorr = namesCorr(inxCorrAllowed);
        valuesCorr = valuesCorr(:, inxCorrAllowed, :);
        if ~addZeroCorr
            posToRemove = find(all(valuesCorr==0, 3));
            valuesCorr(:, posToRemove, :) = [ ];
            namesCorr(posToRemove) = [ ];
        end
        for ii = 1 : numel(namesCorr)
            name__ = namesCorr{ii};
            value__ = permute(valuesCorr(1, ii, :), [2, 3, 1]);
            d.(name__) = value__;
        end
    end%


    function addShocks( )
        d = shockdb(this, d, varargin{:});
    end%
end%

