function plot_single(results, variables, n_iters, i)

    values = [];
    means = [];
    stds = []; % lol
    for j = 1:length(variables{i})
        value = variables{i}(j);
        valid = results(arrayfun(@(r) r.args{i} == value, results));
        [~, best] = max(arrayfun(@(r) r.mean, valid));

        values = [values value];
        means = [means valid(best).mean];
        stds = [stds valid(best).std];
    end

    errorbar(values, means, 2*stds, 'r');
    errorbarlogx
    hold on
    errorbar(values, means, 2*stds/sqrt(n_iters), 'b');
    errorbarlogx
    hold off
