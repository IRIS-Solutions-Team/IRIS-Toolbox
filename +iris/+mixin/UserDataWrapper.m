classdef UserDataWrapper
    properties
        UserData 
    end


    methods
        function this = UserDataWrapper(varargin)
            if nargin==0
                return
            end
            if nargin==1 && isa(varargin{1}, 'UserDataWrapper')
                this = varargin{1};
                return
            end
            this.UserData = varargin{1};
        end


        function data = getUserData(this)
            data = this.UserData;
        end


        function this = setUserData(this, data)
            this.UserData = data;
        end


        function disp(this)
            classOfUserData = class(this.UserData);
            sizeOfUserData = sprintf('%gx', size(this.UserData));
            sizeOfUserData(end) = '';
            fprintf('  UserData: [%s %s]\n', sizeOfUserData, classOfUserData);
            if isstruct(this.UserData)
                disp(this.UserData);
            else
                textual.looseLine( );
            end
        end
    end
end

