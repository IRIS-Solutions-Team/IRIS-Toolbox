% loadobj  Prepare tseries object for loading from disk
%
% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

function this = loadobj(this, varargin)

if isstruct(this)
    s = this;
    this = tseries(s.start, s.data, s.Comment);
    % this = struct2obj(tseries( ), this);
    if ~checkConsistency(this)
        this = tseries( );
    end 
end

this.Start = double(this.Start);

end%

