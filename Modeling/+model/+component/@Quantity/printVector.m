function output = printVector(this, vector, logStyle)

pos = reshape(real(vector), 1, [ ]);
sh = reshape(imag(vector), 1, [ ]);
output = reshape(string(this.Name(pos)), 1, [ ]);

shiftString = repmat("", size(sh));
inxShifts = sh~=0;
shiftString(inxShifts) = "{" + string(sh(inxShifts)) + "}";
output = output + shiftString;

inxLog = this.IxLog(pos);

if any(inxLog)
    if isequal(logStyle, @Behavior)
        logStyle = string(this.Behavior.LogStyleInSolutionVectors);
    end
    if matches(logStyle, "log()")
        output(inxLog) = "log(" + output(inxLog) + ")";
    elseif matches(logStyle, string(this.LOG_PREFIX))
        output(inxLog) = string(this.LOG_PREFIX) + output(inxLog);
    end
end

end%

