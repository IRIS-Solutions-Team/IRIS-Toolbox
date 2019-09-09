classdef (Abstract) Element < handle
    properties
        Caption = ''
        Parent
        Children = cell.empty(1, 0)
        Options = reportMaker.Options(@parent)
        Id = ''
    end


    properties (Abstract)
        Class
        CanBeAdded
    end


    properties (Dependent)
        NumOfChildren
    end


    methods
        function this = Element(caption, varargin)
            if nargin==0
                return
            end
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('reportMaker.element.Element');
                parser.addRequired('Caption', @validateCaption);
            end
            parser.parse(caption);
            this.Caption = caption;
        end%


        function plus(input1, input2)
            add(input1, input2);
        end%


        function flag = canBeAdded(this, input)
            flag = false;
            for i = 1 : numel(this.CanBeAdded)
                if isa(input, this.CanBeAdded{i})
                    flag = true;
                    return
                end
            end
        end%


        function add(parent, child)
            if canBeAdded(parent, child)
                parent.Children{end+1} = child;
                child.Parent = parent;
                return
            end
            THIS_ERROR = { 'Reptile:InvalidObjectsToMerge'
                           'Cannot add %s to %s ' };
            throw( exception.Base(THIS_ERROR, 'error'), ...
                   class(child), class(parent) );
        end%


        function assignOptions(this, varargin)
            for i = 1 : 2 : numel(varargin)
                name = regexprep(varargin{i}, '\W', '');
                value = varargin{i+1};
                if strcmpi(name, 'Id')
                    this.Id = value;
                    continue
                end
                this.Options.(name) = value;
            end
        end%


        function value = get(this, option)
            value = reportMaker.Options.get(this, option);
        end%


        function set(this, option, value)
            reportMaker.Options.set(this, option, value);
        end%


        function detail(this, indent)
            if nargin<2
                indent = '    ';
                textual.looseLine( );
            end
            fprintf('%s%s "%s"\n', indent, class(this), this.Caption);
            indent = [indent, '    '];
            for i = 1 : this.NumOfChildren
                detail(this.Children{i}, indent);
            end
            if nargin<2
                textual.looseLine( );
            end
        end%


        function output = getReport(this, name)
            report = this;
            while ~isa(report, 'reportMaker.Report')
                report = report.Parent;
            end
            if nargin==1
                output = report;
                return
            end
            output = report.(name);
        end%
    end


    methods 
        function value = get.NumOfChildren(this)
            value = numel(this.Children);
        end%


        function this = set.Caption(this, value)
            if ischar(value) || isa(value, 'string')
                this.Caption = char(value);
                return
            end
        end%
    end
end


%
% Local Functions
%


function flag = validateCaption(value)
    flag = ischar(value) || iscellstr(value) || isa(value, 'sting');
end%

