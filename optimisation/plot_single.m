function plot_single(results, variables, n_iters, i, varargin)

    values = [];
    means = [];
    stds = []; % lol
    for j = 1:length(variables{i})
        value = variables{i}(j);
        valid = results(arrayfun(@(r) r.args{i} == value, results));
        [~, best] = max(arrayfun(@(r) r.mean, valid));

        if any(strcmp('show', varargin))
            valid(best)
        end

        values = [values value];
        means = [means valid(best).mean];
        stds = [stds valid(best).std];
    end

    if any(strcmp('stds', varargin))
        errorbar(values, means, 2*stds, 'xr');
        if any(strcmp('logx', varargin))
            errorbarlogx
        end
        hold on
    end

    errorbar(values, means, 2*stds/sqrt(n_iters), 'xb');
    if any(strcmp('logx', varargin))
        errorbarlogx
    end
    hold off
