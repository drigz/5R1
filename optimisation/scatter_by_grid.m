function scatter_by_grid(results, variables, names, a, b)
    clf
    for i=1:length(variables)
        subplot(a,b,i)
        scatter_by(results, variables, i);
        title(['Performance by ' names{i}]);
    end
