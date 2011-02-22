function draw_bump(granularity)
    if nargin < 1
        granularity = 0.03;
    end
    
    [x,y] = meshgrid(0:granularity:10);
    b = bump(x,y);
    b(bump_penalty(x,y) ~= 0) = NaN;
    
    h = surf(x,y,b);
    set(h, 'edgecolor', 'none');
    view(176,36);