function [answ, flag, query] = implementGet(this, query, varargin)
% implementGet  Implement get method for plan objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

TIME_SERIES_CONSTRUCTOR = getappdata(0, 'IRIS_TimeSeriesConstructor');
TEMPLATE_SERIES = TIME_SERIES_CONSTRUCTOR( );

%--------------------------------------------------------------------------

answ = [ ];
flag = true;

switch query
    case {'exogenised', 'exogenized', 'onlyexogenised', 'onlyexogenized'}
        isOnly = strncmp(query, 'only', 4);
        answ = struct( );
        for i = 1 : length(this.XList)
            if isOnly && ~any(this.XAnch(i, :))
                continue
            end
            answ.(this.XList{i}) = replace( ...
                TEMPLATE_SERIES, ...
                +this.XAnch(i, :).', ...
                this.Start, ...
                [this.XList{i}, ' Exogenised points']);
        end
    case {'endogenised', 'endogenized', 'onlyendogenised', 'onlyendogenized'}
        isOnly = strncmp(query, 'only', 4);
        answ = struct( );
        for i = 1 : length(this.NList)
            if isOnly ...
                    && ~any(this.NAnchReal(i, :)) ...
                    && ~any(this.NAnchImag(i, :))
                continue
            end
            answ.(this.NList{i}) = replace( ...
                TEMPLATE_SERIES, ...
                +this.NAnchReal(i, :).' + 1i*(+this.NAnchImag(i, :).'), ...
                this.Start, ...
                [this.NList{i}, ' Endogenised points'] ...
                );
        end
    case 'range'
        answ = this.Start : this.End;
        
    case {'start', 'startdate'}
        answ = this.Start;
        
    case {'end', 'enddate'}
        answ = this.End;
        
    otherwise
        flag = false;
end

end
