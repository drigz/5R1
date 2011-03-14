function draw_ark(ark, varargin)
    hold on
    plot3(ark.args(:,1), ark.args(:,2), ark.objs, varargin{:});
    hold off
