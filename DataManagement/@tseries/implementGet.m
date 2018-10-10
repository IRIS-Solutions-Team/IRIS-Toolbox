function [answ, flag] = implementGet(this, query, varargin)
% implementGet  Implement get method for tseries objects
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

%--------------------------------------------------------------------------

answ = [ ];
flag = true;

switch query
    case {'range', 'first2last', 'start2end', 'first:last', 'start:end'}
        answ = this.Range;
        if ~isa(answ, 'DateWrapper')
            answ = DateWrapper(answ);
        end
        % Bkw compatibility
        answ = answ(:)';
        
        
    case {'min', 'minrange', 'nanrange'}
        sample = all(~isnan(this.Data(:, :)), 2);
        answ = this.Range;
        answ = answ(sample);
        if ~isa(answ, 'DateWrapper')
            answ = DateWrapper(answ);
        end
        
        
    case {'start', 'startdate', 'first'}
        answ = this.Start;
        if ~isa(answ, 'DateWrapper')
            answ = DateWrapper(answ);
        end
    
        
    case {'nanstart', 'nanstartdate', 'nanfirst', 'allstart', 'allstartdate'}
        if isnan(this.Start) || isempty(this.Data)
            answ = DateWrapper.NaD;
        else
            sample = all(~isnan(this.Data(:, :)), 2);
            if isempty(sample) || ~any(sample)
                answ = DateWrapper.NaD;
            else
                pos = find(sample, 1, 'first');
                answ = addTo(this.Start, pos-1);
            end
        end
        
        
    case {'end', 'enddate', 'last'}
        answ = this.End;
        if ~isa(answ, 'DateWrapper')
            answ = DateWrapper(answ);
        end
        
        
    case {'nanend', 'nanenddate', 'nanlast', 'allend', 'allenddate'}
        if isnan(this.Start) || isempty(this.Data)
            answ = DateWrapper.NaD;
        else
            sample = all(~isnan(this.Data(:, :)), 2);
            if isempty(sample) || ~any(sample)
                answ = DateWrapper.NaD;
            else
                pos = find(sample, 1, 'last');
                answ = addTo(this.Start, pos-1);
            end
        end
        
        
    case {'freq', 'frequency', 'per', 'periodicity'}
        answ = DateWrapper.getFrequency(this.Start);
    
        
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
