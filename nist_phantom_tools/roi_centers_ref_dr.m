% test driver for roi_centers_ref

%%nmax = 256
%%mmax = 256

nmax = 192
mmax = 192

gscale = 1.0
xc = nmax/2
yc = nmax/2

for itype = 1:2

  [roi_centers, roi_radii, aux_centers, aux_radii] = ...
         roi_centers_ref(gscale,xc,yc,itype);

  % construct the 14-sphere mask + 3 auxiliary features

  d = zeros(nmax,mmax);
  for id = 1:14
    b = cmask(nmax,roi_radii(id),roi_centers(id,1),roi_centers(id,2));
    d = d + b;
  end

  for id = 1:3
    b = cmask(nmax,aux_radii(id),aux_centers(id,1),aux_centers(id,2));
    d = d + b;
  end

  phantom_mask = d;

  figure;
  imagesc(phantom_mask)
  title(['phantom mask, itype = ', num2str(itype)])
  axis square

end