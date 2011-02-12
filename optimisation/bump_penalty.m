function penalty = bump_penalty(x, y)
% bump_penalty(x, y)
% Returns 0 for solutions that do not violate constraints, and < 0 for
% solutions that do.
    % transform x & y to column vectors
    old_size = size(x);
    x = reshape(x, [], 1);
    y = reshape(y, [], 1);

    terms = [(x-0) (10-x) (y-0) (10-y) (15-x-y) (x.*y - 0.75)];
    terms(terms > 0) = 0;
    % sum along the rows of terms
    penalty = sum(terms, 2);
    size(penalty);
    
    % reshape to original shape
    penalty = reshape(penalty, old_size);
