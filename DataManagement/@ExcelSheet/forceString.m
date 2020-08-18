% forceString  Convert char to string in ExcelSheet buffer

function this = forceString(this)

inx = cellfun(@ischar, this.Buffer);
if any(inx(:))
    this.Buffer(inx) = cellfun(@string, this.Buffer(inx), "UniformOutput", false);
end

end%

