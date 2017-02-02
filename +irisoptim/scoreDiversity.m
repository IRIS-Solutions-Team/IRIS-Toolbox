function [state,options] = scoreDiversity(options,state,flag)
% Plots the best and mean scores of particle swarm.

if strcmp(flag,'init')
    set(gca,'NextPlot','replacechildren',...
        'XLabel',xlabel('Scores'),...
        'YLabel',ylabel('Number of inidividuals'))
end

[n,bins] = hist(state.Score) ;
bar(bins,n,'Tag','scorehistogram','FaceColor',[0.1 0.1 0.5])
end