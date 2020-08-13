function a = cmask(n,r0,cx,cy)
%
% circular mask (disk) of size n and radius r0, located at (cx,cy)
% default radius r0=n/2, default center cx=(n+1)/2, cy=(n+1)/2
% 
  if( nargin < 2 ), r0 = n/2; end

  if( nargin < 4 )
    cx = (n+1)/2;
    cy = (n+1)/2;
  end

  a = circle(n,0,r0,cx,cy);

end
