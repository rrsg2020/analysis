% test driver for edge2d

b = circle(256,0,14.3,120,80);

figure(1)
imagesc(b)
colormap(jet)
colorbar

disp('disk')
[row, col] = rowcol(b);
data = [row col]';

disp('=== odr ===')
[cx,cy,r] = lsqcircle(data,'odr')

disp('=== direct ===')
[cx,cy,r] = lsqcircle(data,'direct')



[c, edge_shift] = edge2d(b,.1);

figure(2)
imagesc(c)
colormap(jet)
colorbar

disp('disk, after edge2d')
[row, col] = rowcol(c);
data = [row col]';

disp('=== odr ===')
[cx,cy,r] = lsqcircle(data,'odr')
cx_corrected = cx - edge_shift
cy_corrected = cy - edge_shift


disp('=== direct ===')
[cx,cy,r] = lsqcircle(data,'direct')
cx_corrected = cx - edge_shift
cy_corrected = cy - edge_shift



