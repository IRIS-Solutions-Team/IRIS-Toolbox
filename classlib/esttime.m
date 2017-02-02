classdef esttime < handle
    % esttime  [Not a public class] Display time to go in the command window.
    
    properties
        startTime = NaN;
        timeString = '';
        hoursToGo = NaN;
        minsToGo = NaN;
        secsToGo = NaN;
        pctDone = NaN;
    end
    
    methods
        
        function This = esttime(varargin)
            textfun.loosespace( );
            if ~isempty(varargin) && ischar(varargin{1})
                disp(varargin{1});
            end
            fprintf('Estimated time to go: ');
            This.startTime = tic( );
        end
        
        function This = update(This,N)
            interTime = toc(This.startTime);
            if N < 1
                timeToGo = interTime*(1-N)/N;
                stop = false;
            else
                timeToGo = 0;
                stop = true;
            end
            hoursToGo = floor(timeToGo / 3600); %#ok<*PROP>
            minsToGo = floor((timeToGo - 3600*hoursToGo)/60);
            secsToGo = floor(timeToGo - 3600*hoursToGo - 60*minsToGo);
            pctDone = round(10*100*N)/10;
            if ~(hoursToGo == This.hoursToGo ...
                    && minsToGo == This.minsToGo ...
                    && secsToGo == This.secsToGo ...
                    && pctDone == This.pctDone)
                timeString = '';
                if hoursToGo > 0
                    timeString = [timeString, ...
                        sprintf('%.0f h ',hoursToGo)];
                end
                if hoursToGo > 0 || minsToGo > 0
                    timeString = [timeString, ...
                        sprintf('%2.0f min ',minsToGo)];
                end
                timeString = [timeString, ...
                    sprintf('%2.0f sec ',floor(secsToGo))];
                timeString = [timeString, ...
                    sprintf('(%.1f per cent done)',pctDone)];
                if ~isempty(This.timeString)
                    bs = sprintf('\b');
                    fprintf(bs(ones(1,length(This.timeString))));
                end
                fprintf(timeString);
                This.timeString = timeString;
                This.hoursToGo = hoursToGo;
                This.minsToGo = minsToGo;
                This.secsToGo = secsToGo;
                This.pctDone = pctDone;
            end
            if stop
                fprintf('\n');
                textfun.loosespace( );
            end
        end
        
    end
    
end