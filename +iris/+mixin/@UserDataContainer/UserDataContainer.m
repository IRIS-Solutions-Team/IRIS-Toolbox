% UserDataContainer  Helper class to implement user data and comments
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 IRIS Solutions Team

classdef UserDataContainer
    properties
% UserData  User data attached to this object
        UserData = []
    end


    properties (Hidden)
% Caption  User caption used to title graphs of this object
        Caption = ''

% BaseYear  Base year for time trends created by this object
        BaseYear = @auto
    end


    methods
        function this = UserDataContainer(varargin)
            if isempty(varargin)
                return
            end
            if isa(varargin{1}, 'iris.mixin.UserDataContainer')
                this = varargin{1};
            else
                this.UserData = varargin{1};
            end
        end%
    end


    methods
        varargout = accessUserData(varargin)
        varargout = assignUserData(varargin)
        varargout = hasUserData(varargin)
        varargout = caption(varargin)
        varargout = userdata(varargin)
        varargout = userdatafield(varargin)
    end


    methods (Hidden)
        varargout = checkConsistency(varargin)
        varargout = implementGet(varargin)
        varargout = implementSet(varargin)
    end



    methods (Access=protected, Hidden)
        function implementDisp(this, varargin)
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

            return

                function str = catchUnknown(x)
                    sizeX = sprintf('%gx', size(x));
                    sizeX(end) = '';
                    str = sprintf('[%s %s]', sizeX, class(x));
                end%
        end%
    end


    methods (Static)
        function fieldName = preprocessFieldName(fieldName)
            fieldName = regexp(fieldName, '\w+', 'match', 'once');
        end%
    end
end

