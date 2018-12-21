function f = results(outp, quantity, solution)

TYPE = @int8;
TIME_SERIES_CONSTRUCTOR = iris.get('DefaultTimeSeriesConstructor');
TIME_SERIES_TEMPLATE = TIME_SERIES_CONSTRUCTOR( );

[ny, ~, nb, nf, ne] = sizeOfSolution(solution);
ixy = quantity.Type==TYPE(1);
ixe = quantity.Type==TYPE(31) | quantity.Type==TYPE(32);
posy = find(ixy);
pose = find(ixe);
start = outp.Range(1);
U = solution.U;

f = struct( );
f.MinLogLik = outp.MinLogLik;
f.VarScale = outp.VarScale;
if outp.StorePredict
    f.Predict.Median = outp2dbase(outp.y0, outp.w0, outp.e0, [ ]);
end
if outp.StoreFilter
    f.Filter.Median = outp2dbase(outp.y1, outp.w1, outp.e1, [ ]);
end
if outp.StoreSmooth
    f.Smooth.Median = outp2dbase(outp.y2, outp.w2, outp.e2, outp.a2);
end
if outp.Ahead>0
    f.Ahead.Median = outp2dbase(outp.yy1, outp.ww1, outp.ee1, [ ]);
end

return




    function d = outp2dbase(y, w, e, init)
        % Measurement variables.
        if ~isempty(y)
            for i = 1 : ny
                name = quantity.Name{ posy(i) };
                data = permute(y(i, :, :), [2, 3, 1]);
                d.(name) = replace(TIME_SERIES_TEMPLATE, data, start);
            end
        end
        
        % Forward-looking transition variables.
        xf = w(1:nf, :, :);
        idf = solution.StateVec(1:nf);
        for i = 1 : nf
            if imag( idf(i) )~=0
                continue
            end
            pos = real( idf(i) );
            name = quantity.Name{pos};
            data = permute(xf(i, :, :), [2, 3, 1]);
            d.(name) = replace(TIME_SERIES_TEMPLATE, data, start);
        end
        
        % Backward-looking transition variables, possibly with initial condition.
        xbStart = start;
        xb = w(nf+1:end, :, :);
        temp = size(xb);
        xb = reshape( U*xb(:,:), temp );
        if ~isempty(init)
            init = reshape( U*init(:,:), size(init) );
            xb = [ init, xb];
            xbStart = start-1;
        end
        idb = solution.StateVec(nf+1:end);
        for i = 1 : nb
            if imag( idb(i) )~=0
                continue
            end
            pos = real( idb(i) );
            name = quantity.Name{pos};
            data = permute(xb(i, :, :), [2, 3, 1]);
            d.(name) = replace(TIME_SERIES_TEMPLATE, data, xbStart);
        end
        
        % Shocks.
        if ~isempty(e)
            for i = 1 : ne
                name = quantity.Name{ pose(i) };
                data = permute(e(i, :, :), [2, 3, 1]);
                d.(name) = replace(tseries, data, start);
            end
        end
    end%
end%

