function display(p)
    clc;
    disp('|==================================================|');
    hashes = floor(p.progress_bar_position*100/2);
    progress_string = ['|' repmat('#', 1, hashes) repmat(' ', 1, 50-hashes) '|'];
    p.relapsed_time=max(toc,0.01);
    disp(progress_string);
    completed=floor(p.progress_bar_position*100);
    
    if completed<100
        fprintf('|================= %2d%% completed ==================|\n', completed);
    else
        disp('|================ 100 % completed =================|');
    end
    minutes=floor((p.relapsed_time/p.progress_bar_position-p.relapsed_time)/ 60);
    seconds=rem((floor(p.relapsed_time/p.progress_bar_position-p.relapsed_time)),60);
    disp(' ');
    if (seconds>9)
        disp(['            Estimated remaining time: ', num2str(minutes),':',num2str(seconds)]);
    elseif (p.progress_bar_position<1)
        disp(['            Estimated remaining time: ', num2str(minutes),':0',num2str(seconds)]);
    end
    minutes=floor(p.relapsed_time/ 60);
    seconds=rem((floor(p.relapsed_time)),60);
    if (seconds>9)
        disp(['            Elapsed time:             ', num2str(minutes),':',num2str(seconds)]);
    else
        disp(['            Elapsed time:             ', num2str(minutes),':0',num2str(seconds)]);
    end
end
