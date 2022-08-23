function y = rearrangePred(x1, x2)

    [data, startDate] = getDataFromTo([x1, x2]);

    nPer = size(data, 1);
    ahead = size(data, 2) - 1;

    data = [ data; nan(ahead, ahead+1) ];
    data1 = data(:, 1);
    data2 = nan(nPer+ahead, nPer);

    for t = 1 : nPer
        row = t+(0:ahead);
        if isnan(data(t, 1))
            continue
        end
        data2(row, t, :) = diag( data(t+(0:ahead), :) );
    end

    y = Series(startDate, [data1, data2]);

end%
