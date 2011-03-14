function scatter_by(results, variables, i, varargin)

    hold all

    colours = varycolor(length(variables{i}));
    markers = '+o*xsd^vph<>';

    set(gca, 'ColorOrder', colours);

    for j = 1:length(variables{i})
        if iscell(variables{i})
            value = variables{i}{j};
        else
            value = variables{i}(j);
        end
        if ischar(value)
            valid = results(arrayfun(@(r) strcmp(r.args{i}, value), results));
        else
            valid = results(arrayfun(@(r) r.args{i} == value, results));
        end
        scatter([valid.mean], [valid.std], 4, markers(j));
        xlabel('mean \mu');
        ylabel('standard deviation \sigma');
        grid on
    end

    if iscell(variables{i})
        legend(variables{i})
    else
        legend(arrayfun(@num2str, variables{i}, 'UniformOutput', false))
    end
