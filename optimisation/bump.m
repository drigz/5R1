function ans = bump(x, y)
    if nargin == 1
        y = x(:,2);
        x = x(:,1);
    end

    cxs = cos(x).^2;
    cys = cos(y).^2;
    ans = abs((cxs.^2 + cys.^2 - 2*cxs.*cys)./sqrt(x.^2+2*y.^2));