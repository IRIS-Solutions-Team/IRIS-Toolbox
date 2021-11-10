% loadobj  Prepare tseries object for loading from disk
%
% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2021 IRIS Solutions Team

function this = loadobj(this, varargin)

if isstruct(this)
    s = this;
    userData = [];
    if isfield(s, 'UserData')
        userData = s.UserData;
    end
    this = tseries(s.start, s.data, s.Comment, userData);
    if ~checkConsistency(this)
        this = tseries( );
    end 
end

this.Start = double(this.Start);

end%

