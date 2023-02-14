function [dx,dy,phi] = image_match2d(a,b,r_phi)
%
%  match two images in R^2, a is fixed, b is rotated and shifted
%
%  a \approx R(phi)*b + (dx,dy)
%

  if( nargin < 3 ), r_phi = -180:10:180; end

  [n,m] = size(a);

  rmax = 0;

  fa = fft2(a);

  for phi0 = r_phi

    c = imrotate(b,phi0,'nearest','crop');

    p = find(~isfinite(c));
    c(p) = 0;

    fc = fft2(c);

    f = fftshift(ifft2(conj(fa).*fc));
    f = real(f);

    [rmax0, idx] = max(f(:));

    if( rmax < rmax0 )
      rmax = rmax0;
      [dx, dy] = ind2sub([n,m], idx(1));
      dx = dx - floor(n/2);
      dy = dy - floor(m/2);
      phi = phi0/180*pi;
    end

  end

  dx = dx - 1;
  dy = dy - 1;

  dx = -dx;
  dy = -dy;

end
