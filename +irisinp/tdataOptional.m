classdef tdataOptional < irisinp.tdata
    methods
        function this = tdataOptional(varargin)
            this = this@irisinp.tdata(varargin{:});
            this.Omitted = NaN;
        end
    end
end
