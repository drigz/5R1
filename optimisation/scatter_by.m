function scatter_by(results, variables, i, varargin)

    hold all

    colours = varycolor(length(variables{i}));
    markers = '+o*xsd^vph<>';

    set(gca, 'ColorOrder', colours);

    for j = 1:length(variables{i})
        value = variables{i}(j);
        valid = results(arrayfun(@(r) r.args{i} == value, results));
        scatter([valid.mean], [valid.std], 4, markers(j));
        xlabel('mean \mu');
        ylabel('standard deviation \sigma');
        grid on
    end

    legend(arrayfun(@num2str, variables{i}, 'UniformOutput', false))
