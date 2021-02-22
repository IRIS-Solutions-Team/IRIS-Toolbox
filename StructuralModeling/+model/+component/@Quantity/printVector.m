function output = printVector(this, vector, logStyle)

try, logStyle = string(logStyle);
    catch, logStyle = "log()"; end

pos = reshape(real(vector), 1, [ ]);
sh = reshape(imag(vector), 1, [ ]);
output = reshape(string(this.Name(pos)), 1, [ ]);

shiftString = repmat("", size(sh));
inxShifts = sh~=0;
shiftString(inxShifts) = "{" + string(sh(inxShifts)) + "}";
output = output + shiftString;

inxLog = this.IxLog(pos);

if ~startsWith(logStyle, "none", "ignoreCase", true) && any(inxLog)
    if startsWith(string(logStyle), "log()")
        output(inxLog) = "log(" + output(inxLog) + ")";
    else
        output(inxLog) = string(logStyle) + output(inxLog);
    end
end

end%

