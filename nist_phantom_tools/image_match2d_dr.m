% test driver for image_match_2d

if( is_octave() )
  pkg load image
end

b = circle(256,0,10,120,80) + circle(256,0,10,180,80);
c = circle(256,0,11,128,128) + circle(256,0,11,128,188);

figure(1)
imagesc(b)
colormap(jet)
colorbar

figure(2)
imagesc(c)
colormap(jet)
colorbar

disp('disk')
[dx,dy,phi] = image_match2d(b,c,-180:180)
phi_degrees = phi * 180/pi

[d, edge_shift] = edge2d(b,.1);

figure(3)
imagesc(d)
colormap(jet)
colorbar

disp('disk, after edge2d')
[dx,dy,phi] = image_match2d(d,c,-180:180)
phi_degrees = phi * 180/pi



