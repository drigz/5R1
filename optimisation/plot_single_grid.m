function plot_single_grid(results, variables, names, n_iters, a, b, varargin)
    clf
    for i=1:length(variables)
        subplot(a,b,i)
        plot_single(results, variables, n_iters, i, varargin{:});
        title(['Performance by ' names{i}]);
    end
