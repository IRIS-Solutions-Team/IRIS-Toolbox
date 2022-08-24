
classdef tseries
    methods (Static)
         function this = loadobj(this, varargin)
            try
                start = this.start;
            catch
                start = this.Start;
            end
            try
                data = this.data;
            catch
                data = this.Data;
            end
            try
                comment = this.comment;
            catch
                comment = this.Comment;
            end
            this = Series(start, data, comment);
        end%
    end
end

