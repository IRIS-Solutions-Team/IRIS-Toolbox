
function dateCode = fromMatlab(freq, matlabDate)

    serial = dater.serialFromYmd(freq, year(matlabDate), month(matlabDate), day(matlabDate));
    dateCode = dater.fromSerial(freq, serial);

end%

