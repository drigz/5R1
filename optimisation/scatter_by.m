function scatter_by(results, variables, i, varargin)

    hold all

    colours = varycolor(length(variables{i}));
    markers = '+o*xsd^vph<>';

    % set(gca, 'ColorOrder', colours);

    for k = 1:10
        subresults = results(randsample(length(results), 100));
        for j = 1:length(variables{i})
            if iscell(variables{i})
                value = variables{i}{j};
            else
                value = variables{i}(j);
            end
            if ischar(value)
                valid = subresults(arrayfun(@(r) strcmp(r.args{i}, value), subresults));
            else
                valid = subresults(arrayfun(@(r) r.args{i} == value, subresults));
            end
            scatter([valid.mean], [valid.std], 4, colours(j, :), markers(j));
            xlabel('mean \mu');
            ylabel('standard deviation \sigma');
            grid on
        end
    end

    if iscell(variables{i})
        legend(variables{i})
    else
        legend(arrayfun(@num2str, variables{i}, 'UniformOutput', false))
    end
