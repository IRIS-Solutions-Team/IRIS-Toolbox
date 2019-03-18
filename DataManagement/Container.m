classdef Container
    properties
        Snapshot = struct( )
    end


    properties (Constant, Hidden)
        CONTAINER_NAME = 'IRIS_Container'
    end


    methods
        function this = Container(varargin)
            this.Snapshot = this.get( );
        end%
    end


    methods (Static)
        function store(varargin)
            Container.createIfNeeded( );
            this = getappdata(0, Container.CONTAINER_NAME);
            for i = 1 : 2 : numel(varargin)
                name = varargin{i};
                name = regexprep(name, '\W', '');
                this.(name) = varargin{i+1};
            end
            setappdata(0, Container.CONTAINER_NAME, this);
        end%


        function varargout = retrieve(varargin)
            if isempty(varargin)
                return
            end
            Container.createIfNeeded( );
            this = getappdata(0, Container.CONTAINER_NAME);
            n = numel(varargin);
            varargout = cell(1, n);
            for i = 1 : n
                varargout{i} = this.(varargin{i});
            end
        end%


        function remove(varargin)
            if isempty(varargin)
                return
            end
            Container.createIfNeeded( );
            this = getappdata(0, Container.CONTAINER_NAME);
            n = numel(varargin);
            for i = 1 : n
                try
                    this = rmfield(this, varargin{i});
                end
            end
            setappdata(0, Container.CONTAINER_NAME, this);
        end%


        function list = getNames( )
            Container.createIfNeeded( );
            this = getappdata(0, Container.CONTAINER_NAME);
            list = transpose(fieldnames(this));
        end%


        function flag = contains(name)
            list = Container.getNames( );
            flag = any(strcmp(list, name));
        end%


        function this = get(varargin)
            Container.createIfNeeded( );
            this = getappdata(0, Container.CONTAINER_NAME);
        end%


        function this = clear( )
            if ~isappdata(0, Container.CONTAINER_NAME)
                return
            end
            rmappdata(0, Container.CONTAINER_NAME);
        end%


        function createIfNeeded( )
            if isappdata(0, Container.CONTAINER_NAME)
                return
            end
            setappdata(0, Container.CONTAINER_NAME, struct( ));
        end%
    end
end

         
