function ark = sa_wrapper(step_method, step_size, penalty_weight, initial_temp, temp_length, temp_decay)
    [ark, ~] = sa(@bump, @bump_penalty, archive_new('single', 1), ...
        step_method, step_size, penalty_weight, initial_temp, temp_length, temp_decay);
