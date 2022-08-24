function this = forceString(this)

inx = cellfun(@ischar, this.Buffer);
if any(inx(:))
    this.Buffer(inx) = cellfun(@string, this.Buffer(inx), 'uniformOutput', false);
end

end%

