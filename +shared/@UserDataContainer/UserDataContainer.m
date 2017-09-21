% UserDataContainer  Helper class to implement user data and comments.
%
% Backend IRIS class.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

classdef UserDataContainer
    properties %(GetAccess=public, SetAccess=protected, Hidden)
        UserData = [ ] % User data attached to objects
        Comment = '' % User comments attached to objects
        Caption = '' % User captions used to title graphs
        BaseYear = @config % Base year for time trends
    end
    
    
    methods
        function this = UserDataContainer(varargin)
            if isempty(varargin)
                return
            end
            if isa(varargin{1}, 'shared.UserDataContainer')
                this = varargin{1};
            else
                this.UserData = varargin{1};
            end
        end
    end
    
    
    methods
        varargout = caption(varargin)
        varargout = comment(varargin)
        varargout = userdata(varargin)
        varargout = userdatafield(varargin)
    end
    
    
    methods (Hidden)
        varargout = chkConsistency(varargin)
        varargout = implementGet(varargin)
        varargout = implementSet(varargin)
        
        
        function disp(this, varargin)
            dispComment(this);
            dispUserData(this);
            if isempty(varargin)
                textfun.loosespace( );
            end
        end
    end
    
    
    methods (Access=protected, Hidden)
        function dispComment(this)
            fprintf('\tcomment: ''%s''\n', this.Comment);
        end
        
        
        function dispUserData(this)
            if isempty(this.UserData)
                msg = 'empty';
            elseif isstruct(this.UserData)
                msg = [ ] ;
                fprintf('\tuser data: \n') ;
                %{
                names = fields(this.UserData) ;
                K = numel(names) ;
                for jj = 1:K
                    x = this.UserData.(names{jj}) ;
                    try
                        str = utils.any2str(x) ;
                    catch
                        str = catchUnknown(x) ;
                    end
                    fprintf('\t\t%s: %s\n', names{jj}, str) ;
                end
                %}
                disp(this.UserData);
            else
                msg = catchUnknown(this.UserData) ;
            end
            if ~isempty(msg)
                fprintf('\tuser data: %s\n',msg);
            end

            return
            
            
            function str = catchUnknown(x)
                tmpSize = sprintf('%gx', size(x));
                tmpSize(end) = '';
                str = sprintf('[%s %s]', tmpSize, class(x));
            end
        end
    end
end
