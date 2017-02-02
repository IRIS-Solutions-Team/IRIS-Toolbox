function implementDisp(this)
TYPE = @int8;
n = [ ...
    sum(this.Type==TYPE(1)), ...
    sum(this.Type==TYPE(2)), ...
    sum(this.Type==TYPE(3) & ~cellfun(@isempty, this.Input)), ...
    sum(this.Type==TYPE(4)), ...
    sum(this.Type==TYPE(5)), ...
    ];
fprintf('\tnumber of equations: [%g %g %g %g %g]\n', n);
end
