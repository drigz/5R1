function plot_single(results, variables, n_iters, i, varargin)

    values = variables{i};
    means = [];
    stds = []; % lol
    for j = 1:length(values)
        if iscell(values)
            value = values{j};
            valid = results(arrayfun(@(r) strcmp(r.args{i}, value), results));
        else
            value = values(j);
            valid = results(arrayfun(@(r) r.args{i} == value, results));
        end
        [~, best] = max(arrayfun(@(r) r.mean-1.645*r.std, valid));

        if any(strcmp('show', varargin))
            valid(best)
        end

        means = [means valid(best).mean];
        stds = [stds valid(best).std];
    end

    if iscell(values)
        names = values;
        values = 1:length(values);
    else
        names = [];
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

    if iscell(names)
        set(gca, 'XTick', [1:length(values)]);
        set(gca, 'XTickLabel', names);
        xlim([0.5 length(values)+0.5]);
    end

    grid on
