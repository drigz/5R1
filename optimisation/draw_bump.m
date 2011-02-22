function draw_bump(granularity)
    if nargin < 1
        granularity = 0.03;
    end
    
    [x,y] = meshgrid(0:granularity:10);
    b = bump(x,y);
    b(bump_penalty(x,y) ~= 0) = NaN;
    
    figure(1);
    h = surf(x,y,b);
    set(h, 'edgecolor', 'none');
    set(figure(1), 'Name', 'Bump');
    view(176,36);