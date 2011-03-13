function results = cli_evaluate(n_iters, varargin)
    n_args = length(varargin);
    arg_counts = cellfun(@length, varargin);
    n_combinations = prod(arg_counts);

    results = struct('args', cell(n_combinations, 1), 'mean', 0, 'std', 0);

    p = progressbar();

    for arg_ind = 1:n_combinations
        [arg_sub{1:n_args}] = ind2sub(arg_counts, arg_ind);

        args = arrayfun(@(i) varargin{i}{arg_sub{i}}, 1:n_args, 'UniformOutput', false);

        cli = strjoin(' ', './sa', num2str(n_iters), args{:});

        [~, ans] = system(cli);
        ans = sscanf(ans, '%f');

        results(arg_ind).args = args;
        results(arg_ind).mean = ans(1);
        results(arg_ind).std = ans(2);

        save('results.mat');

        p = setStatus(p, arg_ind/n_combinations);
        display(p);
    end
