classdef ProgressInfo < handle
    properties
        OneLiner = false
        ShowCompleted = true
        ShowSuccess = true
        ShowTimeElapsed = true
        Total
        TotalString = ''
        Completed = 0
        Success = 0
        StartTime
        TimeNow
        LatestInfoString = ''
    end


    properties (Constant)
        DIVIDER = '  '
    end


    methods
        function this = ProgressInfo(total, oneLiner)
            if nargin==0
                return
            end
            this.Total = total;
            this.OneLiner = oneLiner;
        end%

        
        function update(this)
            try
                this.TimeNow = toc( );
            catch
                tic( );
                this.TimeNow = toc( );
            end
            if isempty(this.StartTime)
                this.StartTime = this.TimeNow;
                textual.looseLine( );
            end
            if ~isempty(this.LatestInfoString) && this.OneLiner
                backspaceString = repmat('\b', 1, length(this.LatestInfoString));
                fprintf(backspaceString);
            end
            infoString = composeInfoString(this);
            fprintf('%s', infoString);
            this.LatestInfoString = infoString;
            if ~this.OneLiner
                fprintf('\n');
                textual.looseLine( );
            end
        end%


        function stop(this)
            if this.OneLiner
                fprintf('\n');
                textual.looseLine( );
            end
        end%


        function infoString = composeInfoString(this)
            infoString = '';
            lenOfTotal = length(this.TotalString);
            if this.ShowCompleted
                completedString = sprintf( 'Completed: %s of %s [%s]%s', ...
                                           printRunningInteger(this, this.Completed), ...
                                           this.TotalString, ...
                                           printPercent(this, this.Completed/this.Total), ...
                                           this.DIVIDER );
                infoString = [infoString, completedString];
            end
            if this.ShowSuccess
                successString = sprintf( 'Success: %s of %s [%s]%s', ...
                                         printRunningInteger(this, this.Success), ...
                                         printRunningInteger(this, this.Completed), ...
                                         printPercent(this, this.Success/this.Completed), ...
                                         this.DIVIDER );
                infoString = [infoString, successString];
            end
            if this.ShowTimeElapsed
                [hours, minutes, seconds] = getHoursMinutesSecondsElapsed(this);
                timeElapsedString = sprintf( 'TimeElapsed: %02.0f:%02.0f:%.2f%s', ... 
                                             hours, minutes, seconds, ...
                                             this.DIVIDER );
                infoString = [infoString, timeElapsedString];
            end
        end%


        function [hours, minutes, seconds] = getHoursMinutesSecondsElapsed(this)
            temp = this.TimeNow - this.StartTime;
            hours = floor(temp/3600);
            temp = temp - 3600*hours;
            minutes = floor(temp/60);
            temp = temp - 60*minutes;
            seconds = temp;
        end%


        function c = printRunningInteger(this, x)
            c = sprintf('%*.0f', length(this.TotalString), x);
            c = strrep(c, ' ', '_');
        end%

        
        function c = printPercent(this, x)
            if ~isfinite(x)
                x = 0;
            end
            c = sprintf('%5.1f%%', 100*x);
            c = strrep(c, ' ', '_');
        end%


        function set.Total(this, value)
            this.Total = value;
            this.TotalString = sprintf('%g', value);
        end%
    end
end

