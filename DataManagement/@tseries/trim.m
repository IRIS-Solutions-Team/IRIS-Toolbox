function this = trim(this)
% trim  Remove leading and trailing missing values from time series data
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

convertToDateWrapper = isa(this.Start, 'DateWrapper');
oldStart = double(this.Start);

[this.Data, newStart] = this.trimRows(this.Data, this.Start, this.MissingValue, this.MissingTest);

if ~isequaln(this.Start, newStart)
    if convertToDateWrapper && ~isa(newStart, 'DateWrapper')
        this.Start = DateWrapper(newStart);
    else
        this.Start = newStart;
    end
end

end%

