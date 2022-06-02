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
        function [label, alias] = splitLabelAlias(inputLabel)
% >=R2019b
%{
            arguments
                inputLabel (1, :) string
            end
%}
% >=R2019b

            SEPARATORS = ["||", "!!"];

            label = string.empty(1, 0);
            alias = string.empty(1, 0);
            for n = reshape(string(inputLabel), 1, [])
                [tokens, separators] = split(n, SEPARATORS);
                if numel(tokens)==1
                    label(end+1) = tokens;
                    alias(end+1) = "";
                elseif numel(tokens)==2
                    label(end+1) = tokens(1);
                    alias(end+1) = tokens(2);
                else
                    label(end+1) = tokens(1);
                    alias(end+1) = join(tokens(2:end), separators(2:end));
                end
            end
            label = strip(label);
            alias = strip(alias);
            label = cellstr(label);
            alias = cellstr(alias);
        end%      
    end
end

