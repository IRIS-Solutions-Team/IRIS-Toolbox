function x = pctmean(this)
x = 100*(geomean(1+this.data/100, 1) - 1);
end