function draw_temp(hObject, eventdata)
value = get(hObject, 'Value');
data = guidata(hObject);

global diag

maxtemp = length(diag.temps);
t = ceil(value * maxtemp);
if t == 0
    t = 1;
end

figure(1)
if ~strcmp(get(figure(1), 'Name'), 'Bump')
    clf;
    draw_bump;
end
title(['T(' num2str(t) ') = ' num2str(diag.temps(t))]);
hold on;
try
    delete(data.hAc);
    delete(data.hRe);
catch
end
data.hAc = plot3(diag.accepts{t}(:,1), diag.accepts{t}(:,2), diag.accepts{t}(:,3), 'go-');
if ~isempty(diag.rejects{t})
    data.hRe = plot3(diag.rejects{t}(:,1), diag.rejects{t}(:,2), diag.rejects{t}(:,3), 'ro');
end
hold off;

guidata(hObject, data);