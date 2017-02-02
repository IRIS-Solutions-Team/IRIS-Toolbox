function [Y,range,YNames,InpFmt,varargin] = myinpdata(this, inp, range)
% myinpdata  [Not a public data] Input data and range including pre-sample for varobj objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------
    
    
    % Database for plain VAR
    %------------------------
    InpFmt = 'dbase';
    
   
    YNames = this.YNames;
    
    usrRng = range;
    [Y,~,range] = db2array(inp,this.YNames,range);
    Y = permute(Y, [2,1,3]);
    
else
    
    % Invalid
    %---------
    utils.error('varobj:myinpdata','Invalid format of input data.');

end

if isequal(usrRng,Inf)
    sample = ~any(any(isnan(Y),3),1);
    first = find(sample,1);
    last = find(sample,1,'last');
    Y = Y(:,first:last,:);
    Rng = Rng(first:last);
end

end