function this = loadobj(this, varargin)
% loadobj  Prepare tseries object for loading from disk
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isstruct(this)
    this = struct2obj(tseries( ), this);
    if ~chkConsistency(this)
        this = tseries( );
    end 
end

if ~isa(this.Start, 'DateWrapper')
    this.Start = DateWrapper(this.Start);
end

end
