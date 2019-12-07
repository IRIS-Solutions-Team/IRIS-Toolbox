classdef Generic < handle
    properties
        Name = ''
        Keyword
        IsEssential = false
        Replace = cell(0, 2)
        Parse = true
    end
    
    
    methods (Abstract)
        varargout = parse(varargin)
    end
    
    
    methods
        function precheck(varargin)
        end%
    end
    
    
    methods (Static)
        function [label, alias] = splitLabelAlias(label)
            if isempty(label)
                alias = label;
                return
            end
            alias = cell(size(label));
            alias(:) = {''};
            for i = 1 : length(label)
                pos = strfind(label{i},'!!');
                if isempty(pos)
                    continue
                end
                alias{i} = label{i}(pos+2:end);
                label{i} = label{i}(1:pos-1);
            end
            alias = strtrim(alias);
            label = strtrim(label);
        end%      
    end
end
