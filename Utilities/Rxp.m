classdef Rxp
    properties
        String (1, 1) string = ""
    end

    methods
        function this = Rxp(varargin)
            if nargin==0
                return
            end
            this.String = string(varargin{:});
        end%


        function s = string(this)
            s = this.String;
        end%


        function varargout = regexp(input, this, varargin)
            [varargout{1:nargout}] = regexp(input, this.String, varargin{:});
        end%


        function varargout = regexprep(this, varargin)
            [varargout{1:nargout}] = regexprep(input, this.String, varargin{:});
        end%
    end
end
