

characters = ['a':'z', 'A':'Z'];

startDate = qq(2020,1);
endDate = startDate + 19;
range = startDate : endDate;
numPeriods = numel(range);

db = struct( );


rdo1 = rephrase.Report( ...
    "Lorem ipsum dolor sit amet" ...
    , "Subtitle", "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras id faucibus felis. Nunc vulputate orci nibh, in aliquam risus finibus viverra." ...
    , "Footer", "Duis ut ultricies lorem. Nullam faucibus pulvinar massa vel faucibus." ...
    , "Class", "" ...
);
rdo2 = copy(rdo1);


table1 = rephrase.Table( ...
    "Table 1"...
    , "Dates", DateWrapper.toIsoString(range) ...
    , "DateFormat", "YYYY:Q" ...
    , "NumDecimals", 3 ...
);
table2 = copy(table1);


for i = 1 : 20
    if i==5
        heading1 = rephrase.Heading( ...
            "Table Heading" ...
        );
        heading2 = copy(heading1);

        table1.Content{end+1} = heading1;
        table2.Content{end+1} = heading2;
    end

    title = "Series " + i;
    if i==1
        title = title + " very-long-unbreakable-series1-title-and-more";
    end
    series1 = rephrase.Series( ...
        "Series " + i ...
    );
    data = rand(numPeriods, 1);
    series1.Content = data;

    name = string(characters(randi(numel(characters), 1, 20)));
    series2 = copy(series1);
    series2.Content = name;
    db.(name) = Series(startDate, data);

    table1.Content{end+1} = series1;
    table2.Content{end+1} = series2;
end


rdo1.Content{end+1} = table1;
rdo2.Content{end+1} = table2;


grid1 = rephrase.Grid( ...
    "", [2, 2] ...
);
grid2 = copy(grid1);


for i = 1 : 4
    chart1 = rephrase.Chart( ...
        "Chart " + i ...
        , "Dates", DateWrapper.toIsoString(range) ...
        , "DateFormat", "YYYY:Q" ...
    );
    chart2 = copy(chart1);

    for j1 = 1 : 2
        id = 100*i+j1;
        args = cell.empty(1, 0);
        if id==401
            args = [args, {"Color", "#000"}];
        end
        series1 = rephrase.Series( ...
            "Series " + (100*i+j1) ...
            , args{:} ...
        );
        data = rand(numPeriods, 1);
        series1.Content = data;

        name = string(characters(randi(numel(characters), 1, 20)));
        series2 = copy(series2);
        series2.Content = name;
        db.(name) = Series(startDate, data);

        chart1.Content{end+1} = series1;
        chart2.Content{end+1} = series2;
    end

    grid1.Content{end+1} = chart1;
    grid2.Content{end+1} = chart2;
end 


rdo1.Content{end+1} = grid1;
rdo2.Content{end+1} = grid2;


j1 = string(jsonencode(rdo1));
fid = fopen("vanillaReport1.json", "w+");
fwrite(fid, j1);
fclose(fid);

j2 = string(jsonencode(rdo2));
fid = fopen("vanillaReport2.json", "w+");
fwrite(fid, j2);
fclose(fid);

db = s.encodeDatabank(db);
jdb = string(jsonencode(db));
fid = fopen("vanillaData2.json", "w+");
fwrite(fid, jdb);
fclose(fid);

