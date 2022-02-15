function [output, specs] = resolveOutputTables(output, specs)

output = reshape(string(output), 1, [ ]);

human.sf = "X11_d10";
human.sa = "X11_d11";
human.tc = "X11_d12";
human.irr = "X11_d13";

for n = reshape(string(fieldnames(human)), 1, [ ])
    output(output==n) = human.(n);
end

list = [
    "Series_a18"
    "Series_a19"
    "Series_b1"
    "Series_mva"

    "X11_d10"
    "X11_d11"
    "X11_d12"
    "X11_d13"
    "X11_d16"
    "X11_d18"

    "Force_saa"
    "Force_rnd"

    "Forecast_fct"
    "Forecast_bct"
    "Forecast_ftr"
    "Forecast_btr"

    "Seats_s10"
    "Seats_s11"
    "Seats_s12"
    "Seats_s13"
    "Seats_s14"
    "Seats_s16"
    "Seats_s18"
    "Seats_cyc"
];

invalidOutput = string.empty(1, 0);
for i = 1 : numel(output)
    if ~contains(output(i), "_")
        inx = endsWith(list, "_" + output(i));
        if any(inx)
            output(i) = list(inx); 
        else
            invalidOutput(end+1) = n;
        end
    end
end

if ~isempty(invalidOutput)
    exception.error([
        "X13:InvalidOutput"
        "This is not a valid output table to request from X13: %s"
    ], invalidOutput);
end

end%

