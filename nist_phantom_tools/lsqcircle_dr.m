% test driver for lsqcircle

b = circle(256,12,14,120,80);
imagesc(b)
colormap(jet)
colorbar

[row, col] = rowcol(b);
data = [row col]';

disp('=== odr ===')
[cx,cy,r] = lsqcircle(data,'odr')

disp('=== direct ===')
[cx,cy,r] = lsqcircle(data,'direct')

disp('=== pratt ===')
[cx,cy,r] = lsqcircle(data,'pratt')

disp('=== taubin ===')
[cx,cy,r] = lsqcircle(data,'taubin')

disp('=== kanatani ===')
[cx,cy,r] = lsqcircle(data,'kanatani')

