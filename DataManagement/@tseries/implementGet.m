function [answ, flag] = implementGet(this, query, varargin)
% implementGet  Implement get method for tseries objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

answ = [ ];
flag = true;

switch query
    case {'range', 'first2last', 'start2end', 'first:last', 'start:end'}
        answ = range(this);
        answ = dates.Date(answ);
    
        
        
        
    case {'min', 'minrange', 'nanrange'}
        sample = all(~isnan(this.Data(:, :)), 2);
        answ = range(this);
        answ = answ(sample);
        answ = dates.Date(answ);

    
        
        
        
    case {'start', 'startdate', 'first'}
        answ = dates.Date(this.Start);
    
        
        
        
    case {'nanstart', 'nanstartdate', 'nanfirst', 'allstart', 'allstartdate'}
        sample = all(~isnan(this.Data(:, :)), 2);
        if isempty(sample)
            answ = NaN;
        else
            answ = this.Start + find(sample, 1, 'first') - 1;
        end
        answ = dates.Date(answ);
        
        
        
        
    case {'end', 'enddate', 'last'}
        answ = endDate(this);
        answ = dates.Date(answ);
    
        
        
        
    case {'nanend', 'nanenddate', 'nanlast', 'allend', 'allenddate'}
        sample = all(~isnan(this.Data(:, :)), 2);
        if isempty(sample)
            answ = NaN;
        else
            answ = this.Start + find(sample, 1, 'last') - 1;
        end
        answ = dates.Date(answ);
        
        
        
        
    case {'freq', 'frequency', 'per', 'periodicity'}
        answ = datfreq(this.Start);
    
        
        
        
    case {'data', 'value', 'values'}
        % Not documented. Use x.Data directly.
        answ = this.Data;
    
        
        
        
    case {'comment', 'comments'}
        % Not documented. User x.Comment directly.
        answ = comment(this);
    
        
        
        
    otherwise
        flag = false;
end

end
