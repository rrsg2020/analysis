function a = circle(n,rmin,rmax,cx,cy)
%
% circular mask of of size n and radii [rmin,rmax], located at (cx,cy)
% default radii rmin=n/4, rmax=n/2, default center cx=(n+1)/2, cy=(n+1)/2
% 

  if( nargin < 3 )
    rmin = n/4;
    rmax = n/2;
  end

  if( nargin < 5 )
    cx = (n+1)/2;
    cy = (n+1)/2;
  end

  if( ~isfinite(rmin) || ~isfinite(rmin) || ~isfinite(rmin) || ~isfinite(rmin) )

    a = zeros(n);
    return

  end

    
  if( rmin == 0 && rmax == 0 )

    a = zeros(n);

  else

    a = ones(n);
    [row,col,p] = rowcol(a);

    x = row;
    y = col;

    r = sqrt((x-cx).^2 + (y-cy).^2);
    idx = find((r<rmin) | (r>rmax));

    a(idx) = 0;

  end

end
