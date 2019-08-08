% UserDataContainer  Helper class to implement user data and comments
%
% Backend IRIS class
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

classdef UserDataContainer
    properties %(GetAccess=public, SetAccess=protected, Hidden)
        % UserData  User data attached to this object
        UserData = [ ] 

        % Caption  User caption used to title graphs of this object
        Caption = '' 

        % BaseYear  Base year for time trends created by this object
        BaseYear = @config 
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
        end%
    end
    
    
    methods
        varargout = caption(varargin)
        varargout = userdata(varargin)
        varargout = userdatafield(varargin)
    end
    
    
    methods (Hidden)
        varargout = checkConsistency(varargin)
        varargout = implementGet(varargin)
        varargout = implementSet(varargin)
        
        
        function disp(this, varargin)
            dispIndent = iris.get('DispIndent');
            if isempty(this.UserData)
                msg = 'Empty';
            elseif isstruct(this.UserData)
                msg = [ ] ;
                fprintf(dispIndent);
                fprintf('User Data: \n') ;
                disp(this.UserData);
            else
                msg = catchUnknown(this.UserData) ;
            end
            if ~isempty(msg)
                fprintf(dispIndent);
                fprintf('User Data: %s\n',msg);
            end
            if isempty(varargin)
                textual.looseLine( );
            end

            return
            
                function str = catchUnknown(x)
                    sizeOfX = sprintf('%gx', size(x));
                    sizeOfX(end) = '';
                    str = sprintf('[%s %s]', sizeOfX, class(x));
                end%
        end%
    end
end

